dnl dnl -*-m4-*-
dnl 
dnl ##
dnl ## $Id: apache_config.m4,v 1.2 2010/10/13 19:56:31 rlauer Exp $
dnl ##
dnl 
dnl This file provides the 'APACHE_CONFIG' autoconf macro, which may be
dnl used to provide support for configuring Apache websites
dnl 
dnl autoconf variables provided by this macro include:
dnl 
dnl apache_vhostdir       => the directory where all the virtual hosts reside
dnl                          examples: /usr/local/vhosts, /var, /var/www, etc.
dnl apache_vhost_confdir  => the directory where all the virtaul host configuration files reside 
dnl                          examples: /etc/httpd/conf.d, /etc/apache2/sites-available, /usr/local/bin/conf/conf.d
dnl apache_vhost_config   => the name of the apache virtual host configuration file
dnl                          examples: www.signatureinfo.conf.in
dnl apache_vhost_domain   => the domain name of the website 
dnl                          examples: signatureinfo.com, charlesjones.com
dnl apache_vhost_server   => the fully qualified domain name (including subdomain) of the website
dnl                          examples: mars.signatureinfo.com, cjops.charlesjones.com
dnl apache_user           => the user that runs the apache server
dnl                          examples: www-data, apache, nobody
dnl apache_group          => the group the user that runs apache belongs to
dnl                          examples: www-data, apache, nobody 
dnl
dnl Dependencies
dnl ============
dnl 
dnl NONE
dnl 
dnl Usage
dnl =====
dnl 
dnl APACHE_CONFIG
dnl
dnl You might find a Makefile.am similar to that found below helpful.
dnl
dnl    SUBDIRS = .
dnl    
dnl    apache_vhostdir =  @apache_vhostdir@
dnl    
dnl    apache_vhost_config = @apache_vhost_config@
dnl    
dnl    apache_user  = @apache_user@
dnl    apache_group = @apache_group@
dnl    
dnl    apache_vhost_domain  = @apache_vhost_domain@
dnl    apache_vhost_server  = @apache_vhost_server@
dnl    apache_vhost_confdir = @apache_vhost_confdir@
dnl    apache_vhost_config  = @apache_vhost_config@
dnl    
dnl    apache_sitedir = $(apache_vhost_dir)/$(apache_vhost_server)
dnl    
dnl    apache_site_configdir  = $(apache_sitedir)/config
dnl    apache_site_cgibindir  = $(apache_sitedir)/cgi-bin
dnl    apache_site_htmldir    = $(apache_sitedir)/html
dnl    apache_site_logdir     = $(apache_sitedir)/logs
dnl    
dnl    @do_subst_command@
dnl    
dnl    CONFIG = \
dnl        vhost-template.conf.in
dnl    
dnl    GCONFIG = \
dnl        $(apache_vhost_config)
dnl        
dnl    apache_vhost_conf_DATA = $(GCONFIG)
dnl    dist_noinst_DATA = $(CONFIG)
dnl    
dnl    $(GCONFIG): $(CONFIG)
dnl            $(do_subst) $< > $@
dnl    
dnl    all:
dnl    
dnl    CLEANFILES = $(GCONFIG)
dnl    
dnl You might also find some useful things in the autoconf-template-bedrock project
dnl
AC_DEFUN([APACHE_CONFIG],[
    dnl APACHE configuration
    AC_ARG_WITH(
    	[apache-vhost-domain],[  --with-apache-vhost-domain=name],
    	[apache_vhost_domain=$withval]
    	)
    
    if test -z "$apache_vhost_domain"; then
      AC_MSG_WARN([You don't have a domain name, so you won't have a ServerAlias])
    else
      apache_vhost_alias="ServerAlias ${apache_vhost_domain}"
      AC_SUBST([apache_vhost_alias])
      AC_SUBST([apache_vhost_domain])
    fi

    apache_vhostdir=${localstatedir}/www
    AC_ARG_WITH(
    	[apache-vhostdir],[  --with-apache-vhostdir=DIR],
    	[apache_vhostdir=$withval]
    	)
    
    AC_SUBST([apache_vhostdir])

    dnl typical locations for configuration directory based on distro
    if test -z "$apache_vhost_confdir"; then
      if test -f /etc/debian_version; then
        if test -d /etc/apache2/sites-available; then
          apache_vhost_confdir=/etc/apache2/sites-available
        fi
      elif test -f /etc/redhat-release; then
         if test -d /etc/httpd/conf.d; then
           apache_vhost_confdir=/etc/httpd/conf.d
         fi
      else
         apache_vhost_confdir=${sysconfdir}/httpd/conf.d
      fi
    fi

    AC_ARG_WITH(
    	[apache-vhost-confdir],[  --with-apache-vhost-confdir=DIR, where Apache looks for virtual host configuration files],
    	[apache_vhost_confdir=$withval]
    	)
    
    AC_SUBST([apache_vhost_confdir])

    AC_MSG_RESULT([Apache configuration directory set to ${apache_vhost_confdir}?])
    
    if test -z "$apache_vhost_domain"; then
      apache_vhost_server=localhost
    else
      apache_vhost_server=www.${apache_vhost_domain}
    fi

    AC_ARG_WITH(
    	[apache-vhost-server],[  --with-apache-vhost-server=name, default: localhost],
    	[apache_vhost_server=$withval]
    	)
    
    AC_SUBST([apache_vhost_server])

    dnl Your Apache virtual host config file should be named thusly
    apache_vhost_config=${apache_vhost_server}.conf
    AC_SUBST([apache_vhost_config])

    dnl Try to guess apache user
    apache_user=$(id www-data 2>/dev/null)
    
    if test -z "$apache_user"; then
      apache_user=$(id apache 2>/dev/null)
      if ! test -z "$apache_user"; then
        apache_user=apache
        apache_group=apache
      fi
    else
      apache_user=www-data
      apache_group=www-data
    fi
    
    AC_MSG_RESULT([apache user = ${apache_user} ?])
    AC_MSG_RESULT([apache group = ${apache_user} ?])
    
    AC_ARG_WITH(
    	[apache-user],[  --with-apache-user=USER          user id that should own the web pages],
    	[apache_user=$withval],
	[apache_user=${apache_user}]
    	)
    
    AC_SUBST([apache_user])
    
    AC_ARG_WITH(
    	[apache-group],[  --with-apache-group=GROUP        group that should own the web pages],
    	[apache_group=$withval],
	[apache_user=${apache_user}]
    	)
    
    AC_SUBST([apache_group])

    AC_ARG_WITH([apache_port],[  --with-apache-port ],
    	[apache_port=$withval],
        [apache_port=80]
        )       

   AC_SUBST([apache_port])

    AC_ARG_WITH([apache_loglevel],[  --with-apache-loglevel ],
    	[apache_loglevel=$withval],
        [apache_loglevel=info]
        )       

    AC_SUBST([apache_loglevel])
])

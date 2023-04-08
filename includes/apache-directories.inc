# -*- mode: makefile; -*-

# Apache Virtual Host site directories
#apache_vhost_dir          = @apache_vhcoredir@
apache_sitedir            = $(apache_vhostdir)
apache_site_cachedir      = $(apache_sitedir)/cache
apache_site_cgibindir     = $(apache_sitedir)/cgi-bin
apache_site_configdir     = $(apache_sitedir)/config
apache_site_htdocsdir     = $(apache_sitedir)/html
apache_site_imgdir        = $(apache_sitedir)/html/img
apache_site_imagesdir     = $(apache_sitedir)/html/images
apache_site_javascriptdir = $(apache_sitedir)/html/javascript
apache_site_cssdir        = $(apache_sitedir)/html/css
apache_site_includedir    = $(apache_sitedir)/include
apache_site_logdir        = $(apache_sitedir)/log
apache_site_sessiondir    = $(apache_sitedir)/session
apache_site_spooldir      = $(apache_sitedir)/spool
apache_site_workdir       = $(apache_sitedir)/work
apache_site_perl5libdir   = $(apache_sitedir)/share/perl5
site_perl5libdir          = $(apache_sitedir)/share/perl5

httpd_confdir             = $(sysconfdir)/httpd/conf
httpd_confddir            = $(sysconfdir)/httpd/conf.d

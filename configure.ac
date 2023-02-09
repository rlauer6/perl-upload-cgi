AC_INIT([perl-upload-cgi],
        m4_esyscmd_s([
if test -z "$VERSION"; then \
  VERSION=$(test -e VERSION && cat VERSION); \
  VERSION=${VERSION:-0.0.0}; \
fi; \
echo $VERSION
]),
        m4_esyscmd_s([if test -z "$EMAIL"; then EMAIL=rclauer@gmail.com; fi; echo $EMAIL]),[perl-upload-cgi])

__poor_mans_expand_file_name () {
    _tmp_name=$1
    _tmp_last="`eval echo '${'"${_tmp_name}"'}'`"
    if test -z "${_tmp_last}"; then
        printf "__poor_mans_expand_file_name() (WARNING): var \"%s\" is empty\n" \
          "${_tmp_name}" 1>&2
        return 0;  # nothing to do
    fi
    _tmp_last_expanded="`eval echo ${_tmp_last}`"
    while test "${_tmp_last_expanded}" != "${_tmp_last}"; do

        # Set 'last' hold var to most recently expanded version...
        _tmp_last="${_tmp_last_expanded}"

        # ...and try to expand further.
        _tmp_last_expanded="`eval echo ${_tmp_last_expanded}`"
    done
    printf "%s\n" "${_tmp_last_expanded}"
    unset _tmp_last_expanded
    unset _tmp_last
    unset _tmp_name
    return 0;
}

[
do_subst_command='do_subst = sed \
  -e '"'"'s,[@]PACKAGE[@],$(PACKAGE),g'"'"' \
  -e '"'"'s,[@]VERSION[@],$(VERSION),g'"'"' \
  -e '"'"'s,[@]LICENSE[@],$(LICENSE),g'"'"' \
  -e '"'"'s,[@]PACKAGE_VERSION[@],$(PACKAGE_VERSION),g'"'"' \
  -e '"'"'s,[@]ARCHITECTURE[@],$(ARCHITECTURE),g'"'"' \
  -e '"'"'s,[@]VERSION[@],$(VERSION),g'"'"' \
  -e '"'"'s,[@]PATH_SEPARATOR[@],$(PATH_SEPARATOR),g'"'"' \
  -e '"'"'s~[@]configure_input[@]~Generated from $@.in; do not edit by hand.~g'"'"' \
  -e "s,[@]BUILD_DATE[@],$$(date '"'"'+%Y-%m-%d %H:%M:%S'"'"'),g" \
  \
  -e '"'"'s,[@]bindir[@],$(bindir),g'"'"' \
  -e '"'"'s,[@]datadir[@],$(datadir),g'"'"' \
  -e '"'"'s,[@]exec_prefix[@],$(exec_prefix),g'"'"' \
  -e '"'"'s,[@]includedir[@],$(includedir),g'"'"' \
  -e '"'"'s,[@]infodir[@],$(infodir),g'"'"' \
  -e '"'"'s,[@]libdir[@],$(libdir),g'"'"' \
  -e '"'"'s,[@]libexecdir[@],$(libexecdir),g'"'"' \
  -e '"'"'s,[@]localstatedir[@],$(localstatedir),g'"'"' \
  -e '"'"'s,[@]mandir[@],$(mandir),g'"'"' \
  -e '"'"'s,[@]oldincludedir[@],$(oldincludedir),g'"'"' \
  -e '"'"'s,[@]prefix[@],$(prefix),g'"'"' \
  -e '"'"'s,[@]sbindir[@],$(sbindir),g'"'"' \
  -e '"'"'s,[@]sharedstatedir[@],$(sharedstatedir),g'"'"' \
  -e '"'"'s,[@]sysconfdir[@],$(sysconfdir),g'"'"' \
  \
  -e '"'"'s,[@]abs_builddir[@],$(abs_builddir),g'"'"' \
  -e '"'"'s,[@]abs_srcdir[@],$(abs_srcdir),g'"'"' \
  -e '"'"'s,[@]abs_top_builddir[@],$(abs_top_builddir),g'"'"' \
  -e '"'"'s,[@]abs_top_srcdir[@],$(abs_top_srcdir),g'"'"' \
  -e '"'"'s,[@]srcdir[@],$(srcdir),g'"'"' \
  -e '"'"'s,[@]top_builddir[@],$(top_builddir),g'"'"' \
  -e '"'"'s,[@]top_srcdir[@],$(top_srcdir),g'"'"' \
\
  -e '"'"'s,[@]perl5libdir[@],$(perl5libdir),g'"'"' \
  -e '"'"'s,[@]perlrun[@],$(perlrun),g'"'"' \
  -e '"'"'s,[@]ksh[@],$(ksh),g'"'"' \
  -e '"'"'s,[@]bashrun[@],$(bashrun),g'"'"' \
  -e '"'"'s,[@]logdir[@],$(logdir),g'"'"' \
\
  -e '"'"'s,[@]apache_user[@],$(apache_user),g'"'"' \
  -e '"'"'s,[@]apache_group[@],$(apache_group),g'"'"' \
  -e '"'"'s,[@]apache_sitedir[@],$(apache_sitedir),g'"'"' \
  -e '"'"'s,[@]apache_site_logdir[@],$(apache_site_logdir),g'"'"' \
  -e '"'"'s,[@]apache_site_configdir[@],$(apache_site_configdir),g'"'"' \
  -e '"'"'s,[@]apache_site_cgibindir[@],$(apache_site_cgibindir),g'"'"' \
  -e '"'"'s,[@]apache_site_htdocsdir[@],$(apache_site_htdocsdir),g'"'"' \
  -e '"'"'s,[@]apache_site_imgdir[@],$(apache_site_imgdir),g'"'"' \
  -e '"'"'s,[@]apache_site_cssdir[@],$(apache_site_cssdir),g'"'"' \
  -e '"'"'s,[@]apache_site_javascriptdir[@],$(apache_site_javascriptdir),g'"'"' \
  -e '"'"'s,[@]apache_site_workdir[@],$(apache_site_workdir),g'"'"' \
  -e '"'"'s,[@]apache_site_spooldir[@],$(apache_site_spooldir),g'"'"' \
  -e '"'"'s,[@]apache_site_sessiondir[@],$(apache_site_sessiondir),g'"'"' \
  -e '"'"'s,[@]apache_site_cachedir[@],$(apache_site_cachedir),g'"'"' \
  -e '"'"'s,[@]apache_site_perl5libdir[@],$(apache_site_perl5libdir),g'"'"' \
\
  -e '"'"'s,[@]apache_site_work_dir[@],$(apache_site_work_dir),g'"'"' \
  -e '"'"'s,[@]apache_site_spool_dir[@],$(apache_site_spool_dir),g'"'"' \
\
  -e '"'"'s,[@]apache_site_reportsdir[@],$(apache_site_reportsdir),g'"'"' \
  -e '"'"'s,[@]apache_vhost_dir[@],$(apache_vhost_dir),g'"'"' \
  -e '"'"'s,[@]apache_vhost_confdir[@],$(apache_vhost_confdir),g'"'"' \
  -e '"'"'s,[@]apache_vhost_domain[@],$(apache_vhost_domain),g'"'"' \
  -e '"'"'s,[@]apache_vhost_server[@],$(apache_vhost_server),g'"'"' \
  -e '"'"'s,[@]apache_vhost_alias[@],$(apache_vhost_alias),g'"'"' \
\
  -e '"'"'s,[@]bucket_name[@],$(bucket_name),g'"'"' \
  -e '"'"'s,[@]profile[@],$(profile),g'"'"' \
  -e '"'"'s,[@]s3_host[@],$(s3_host),g'"'"' \
'
]

AC_SUBST([do_subst_command])

AC_CONFIG_AUX_DIR([autotools])
AC_CONFIG_MACRO_DIR([autotools])

AM_INIT_AUTOMAKE([-Wall -Wno-portability  -Wno-override foreign tar-ustar])

AC_PATH_PROG([BASHRUN],
	[bash])

if test -z "$BASHRUN" ; then 
  AC_MSG_ERROR([bash not found?])
fi

AC_PATH_PROG([PERL],
	[perl])

if test -z "$PERL" ; then 
  AC_MSG_ERROR([perl not found?])
fi

AC_PATH_PROG([POD2MARKDOWN],
	[pod2markdown])

if test -z "$POD2MARKDOWN" ; then 
  AC_MSG_ERROR([pod2markdown found?])
fi

AC_PATH_PROG([RPMBUILD],
	[rpmbuild])

if test -z "$RPMBUILD" ; then 
  AC_MSG_WARN([rpmbuild not found?])
fi

AC_PATH_PROG([POD2MAN],
	[pod2man])

if test -z "$POD2MAN" ; then 
  AC_MSG_ERROR([pod2man found?])
fi

AC_PATH_PROG([PERLCRITIC],
	[perlcritic])

if test -z "$PERLCRITIC" ; then 
  AC_MSG_WARN([perlcritic not found?])
fi

AC_PATH_PROG([SCANDEPS],
	[scandeps-static.pl])

if test -z "$SCANDEPS" ; then 
  AC_MSG_WARN([scandeps-static.pl not found?])
fi

perl5libdir=\${datadir}/perl5
AC_ARG_WITH(
	[perl5libdir],[  --with-perl5libdir (defaults to [DATAROOTDIR]/perl5)],
	[
    if test "${withval}" = 'no'; then
        true
    elif test "$withval" = 'yes'; then
        perl5libdir=$($PERL -MConfig -wle 'print $Config{sitelib};')
    else
        perl5libdir=$withval    
    fi
        ]
)

AX_REQUIRED_PERL_MODULES

AC_SUBST([perl5libdir])

APACHE_CONFIG
AX_DISTCHECK_HACK
AX_DEPS_CHECK
AX_PERLDEPS_CHECK

RPM_BUILD_MODE
PERLCRITIC_MODE
AX_REQUIREMENTS_CHECK

AC_ARG_WITH([bucket_name],[  --with-bucket-name ],
	[bucket_name=$withval],
        [bucket_name=test-bucket],
)

AC_SUBST([bucket_name])

AC_ARG_WITH([profile],[  --with-profile ],
	[profile=$withval],
        [profile=localstack]
)

AC_SUBST([profile])

AC_ARG_WITH([s3_host],[  --with-s3-host ],
	[s3_host=$withval],
        [s3_host=s3.localhost.localstack.cloud]
)

AC_SUBST([s3_host])

AC_ARG_WITH([license],[  --with-license (defaults to GNU Public License)],
	[LICENSE=$withval],
        [LICENSE=["GNU Public License"]]
)

AC_SUBST([LICENSE])

AC_ARG_WITH([architecture],[  --with-architecture (defaults to noarch)],
	[ARCHITECTURE=$withval],
        [ARCHITECTURE=noarch]
)

AC_SUBST([ARCHITECTURE])

AC_CONFIG_FILES([
    Makefile
    src/Makefile
    src/main/Makefile
    src/main/javascript/Makefile
    src/main/images/Makefile
    src/main/perl/Makefile
    src/main/perl/lib/Makefile
    src/main/perl/bin/Makefile
    src/main/perl/cgi-bin/Makefile
    src/main/bash/Makefile
    src/main/bash/bin/Makefile
    config/Makefile
    resources/Makefile
])

AC_OUTPUT

printf "\n"
printf "${PACKAGE} has been configured with the following options:\n"
printf "                        Prefix: %s\n" "`__poor_mans_expand_file_name prefix`"
printf "                 User binaries: %s\n" "`__poor_mans_expand_file_name bindir`"
printf "               System binaries: %s\n" "`__poor_mans_expand_file_name sbindir`"
printf "           Configuration files: %s\n" "`__poor_mans_expand_file_name sysconfdir`"
printf "                   State files: %s\n" "`__poor_mans_expand_file_name localstatedir`"
printf "                  Manual pages: %s\n" "`__poor_mans_expand_file_name mandir`"
printf "\n"
printf "                   perl5libdir: %s\n" "`__poor_mans_expand_file_name perl5libdir`"
printf "\n"
printf "                          perl: %s\n" "`__poor_mans_expand_file_name PERL`"
printf "                          bash: %s\n" "`__poor_mans_expand_file_name BASHRUN`"
printf "\n"
printf "                  Architecture: %s\n" "`__poor_mans_expand_file_name ARCHITECTURE`"
printf "                       License: %s\n" "`__poor_mans_expand_file_name LICENSE`"
printf "\n"
printf "                    Maintainer: ${PACKAGE_BUGREPORT}\n"
printf "                       Version: ${PACKAGE_VERSION}\n"
printf "\n"
printf "                        Bucket: %s\n" "`__poor_mans_expand_file_name bucket_name`"
printf "                       S3 Host: %s\n" "`__poor_mans_expand_file_name s3_host`"
printf "                       Profile: %s\n" "`__poor_mans_expand_file_name profile`"

SUBDIRS = .

include $(top_srcdir)/includes/directories.inc
include $(top_srcdir)/includes/apache-directories.inc


if APACHE_LOG_CONSOLE
# useful when running in a Docker container
error_log  = /dev/stdout
custom_log = /dev/stdout combined
else
error_log  = $(apache_site_logdir)/error_log
custom_log = $(apache_site_logdir)/access_log combined
endif

workflow_configdir = $(sysconfdir)/workflow/config.d

systemddir = $(sysconfdir)/systemd/system

SERVICE_CONFIG = \
    inotify.service.in

# Workflow::Inotify::Handler (inotify.pl) configuration file
INI_CONFIG = \
    upload.cfg.in

PROGRESS_CONFIG = \
    apache2-upload-progress-redis.conf

HTTP_CONFIG = \
    perl-upload-cgi.conf.in

GHTTP_CONFIG=$(HTTP_CONFIG:.conf.in=.conf)

httpd_confd_DATA = $(GHTTP_CONFIG)

# upload.cgi configuration file
JSON_CONFIG = \
    apache2-upload-progress.json.in

GJSON_CONFIG = $(JSON_CONFIG:.json.in=.json)

GINI_CONFIG = $(INI_CONFIG:.cfg.in=.cfg)

GSERVICE_CONFIG = $(SERVICE_CONFIG:service.in=service)

apache_site_config_DATA = \
    $(GJSON_CONFIG)

workflow_config_DATA = \
    $(GINI_CONFIG)

progress_configdir = $(datadir)/$(PACKAGE)

dist_progress_config_DATA = \
    $(PROGRESS_CONFIG)

systemd_DATA = \
    $(GSERVICE_CONFIG)

dist_noinst_DATA = \
    $(JSON_CONFIG) \
    $(INI_CONFIG) \
    $(SERVICE_CONFIG) \
    $(HTTP_CONFIG)

@do_subst_command@

$(GHTTP_CONFIG): % : %.in
	$(do_subst) $< > $@

$(GJSON_CONFIG): % : %.in
	$(do_subst) $< > $@

$(GINI_CONFIG): % : %.in
	$(do_subst) $< > $@

$(GSERVICE_CONFIG): % : %.in
	$(do_subst) $< > $@

all:

CLEANFILES = \
    $(GJSON_CONFIG) \
    $(GHTTP_CONFIG) \
    $(GINI_CONFIG) \
    $(GSERVICE_CONFIG)

WEBSERVER_DIRS = \
    $(apache_site_cgibindir) \
    $(apache_site_configdir) \
    $(apache_site_htdocsdir) \
    $(apache_site_imgdir) \
    $(apache_site_imagesdir) \
    $(apache_site_javascriptdir) \
    $(apache_site_cssdir) \
    $(apache_site_includedir) \
    $(apache_site_logdir) \
    $(apache_site_sessiondir) \
    $(apache_site_spooldir)

install-data-local:
	for a in $(WEBSERVER_DIRS); do \
	  $(MKDIR_P) $(DESTDIR)$$a; \
	  if [ $$(id -u) = "0" ]; then \
	    chown $(apache_user):$(apache_group) $$a; \
	  fi \
	done

uninstall-local:
	for a in  $(WEBSERVER_DIRS); do \
	  rmdir $(DESTDIR)$$a 2>/dev/null || : ; \
	done

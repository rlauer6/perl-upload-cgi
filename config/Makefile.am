SUBDIRS = .

include $(top_srcdir)/includes/directories.inc
include $(top_srcdir)/includes/apache-directories.inc

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
    $(GINI_CONFIG) \
    $(GSERVICE_CONFIG)

WEBSERVER_DIRS = \
    cgi-bin \
    config \
    htdocs \
    htdocs/css \
    htdocs/images \
    htdocs/javascript \
    log

install-data-local:
	$(MKDIR_P) $(DESTDIR)$(localstatedir)/spool/$(PACKAGE)
	for a in $(WEBSERVER_DIRS); do \
	  $(MKDIR_P) $(DESTDIR)$(apache_vhostdir)/$$a; \
	done

uninstall-local:
	rmdir $(DESTDIR)$(localstatedir)/spool/$(PACKAGE) 2>/dev/null || :
	for a in  $(WEBSERVER_DIRS); do \
	  rmdir $(DESTDIR)$(apache_vhostdir)/$$a 2>/dev/null || : ; \
	done

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

# upload.cgi configuration file
JSON_CONFIG = \
    upload.json.in

GJSON_CONFIG = $(JSON_CONFIG:.json.in=.json)

GINI_CONFIG = $(INI_CONFIG:.cfg.in=.cfg)

GSERVICE_CONFIG = $(SERVICE_CONFIG:service.in=service)

apache_site_config_DATA = \
    $(GJSON_CONFIG)

workflow_config_DATA = \
    $(GINI_CONFIG)

systemd_DATA = \
    $(GSERVICE_CONFIG)

dist_noinst_DATA = \
    $(JSON_CONFIG) \
    $(INI_CONFIG) \
    $(SERVICE_CONFIG)

@do_subst_command@

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

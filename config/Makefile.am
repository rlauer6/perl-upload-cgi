SUBDIRS = .

include $(top_srcdir)/includes/directories.inc
include $(top_srcdir)/includes/apache-directories.inc

workflow_configdir = $(sysconfdir)/workflow/config.d

systemddir = $(sysconfdir)/systemd/system

# systemd service configuration
# systemctl start inotify
# systemctl stop inotify
# systemctl reload inotify (SIGHUP)
# systemctl daemon-reload (required when configuration changes)

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


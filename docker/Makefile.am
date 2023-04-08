SUBDIRS = .

include $(top_srcdir)/includes/directories.inc
include $(top_srcdir)/includes/apache-directories.inc

@do_subst_command@

all: $(GHTTPD_CONFIG) $(GDOCKER_COMPOSE)

HTTPD_CONFIG = httpd.conf.in
GHTTPD_CONFIG = $(HTTPD_CONFIG:.conf.in=.conf)

$(GHTTPD_CONFIG): $(HTTPD_CONFIG)
	$(do_subst) $< > $@

DOCKER_COMPOSE = docker-compose.yaml.in
GDOCKER_COMPOSE = $(DOCKER_COMPOSE:.yaml.in=.yaml)

$(GDOCKER_COMPOSE): $(DOCKER_COMPOSE)
	$(do_subst) $< > $@

httpd_conf_DATA = $(GHTTPD_CONFIG)

dist_noinst_DATA = $(HTTPD_CONFIG) $(DOCKER_COMPOSE)

CLEANFILES = \
    $(GHTTPD_CONFIG) \
    $(GDOCKER_COMPOSE)


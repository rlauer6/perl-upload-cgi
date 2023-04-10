#-*- mode: makefile-gmake; -*-
SUBDIRS = .

include $(top_srcdir)/includes/apache-directories.inc
include $(top_srcdir)/includes/directories.inc

TEMPLATES = \
    templates/upload-form.tt \
    templates/config-form.tt

dist_apache_site_include_DATA = \
    $(TEMPLATES)

dist_resources_DATA = \
    $(TEMPLATES)

#-*- mode: makefile-gmake; -*-
SUBDIRS = .

include $(top_srcdir)/includes/apache-directories.inc
include $(top_srcdir)/includes/directories.inc

TEMPLATES = \
    templates/upload-form.tt \
    templates/config-form.tt \
    templates/config-form-upload.tt \
    templates/config-form-redis.tt \
    templates/config-form-session.tt \
    templates/save-cancel.tt \
    templates/spinner.tt \
    templates/toast.tt

dist_apache_site_include_DATA = \
    $(TEMPLATES)

dist_resources_DATA = \
    $(TEMPLATES)

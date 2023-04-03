#-*- mode: makefile-gmake; -*-
SUBDIRS = .

include $(top_srcdir)/includes/apache-directories.inc
include $(top_srcdir)/includes/directories.inc
include $(top_srcdir)/includes/perlcritic.inc
include $(top_srcdir)/includes/perl-cgi-bin.inc

all:

CLEANFILES = \
    $(GPERLSCRIPTS) \
    $(GPERLCRITIC_PL) \
    $(GCGISCRIPTS)

.PHONY: clean-local
clean-local:
	$(MAKE) clean-generated-man-pages
	rm -f *.log

.PHONY: clean-generated-man-pages
clean-generated-man-pages:
	for mpath in $(G1MANPAGES); do \
	rm -f "$${mpath}" ;\
	test $$? -eq 0 || exit 1 ;\
	done

if DISTCHECK_HACK
else
endif

if RPM_BUILD_MODE
else
install-data-hook:
	for a in $(GCGISCRIPTS); do \
	  chmod +x $(DESTDIR)$(apache_site_cgibindir)/$$a; \
	done
endif

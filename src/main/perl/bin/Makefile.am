SUBDIRS = .

include $(top_srcdir)/includes/directories.inc
include $(top_srcdir)/includes/perlcritic.inc
include $(top_srcdir)/includes/perl-bin.inc

.PHONY: test
test: $(GPERLSCRIPTS)
	test -d t/ && PERL5LIB=../lib prove -v t/

all:

CLEANFILES = \
    $(GPERLSCRIPTS) \
    $(GPERLCRITIC_PL)

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
endif

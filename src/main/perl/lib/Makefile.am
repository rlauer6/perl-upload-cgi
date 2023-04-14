SUBDIRS = .

include $(top_srcdir)/includes/directories.inc
include $(top_srcdir)/includes/perl-modules.inc
include $(top_srcdir)/includes/perlcritic.inc

GALLMODULES = $(ALLMODULES:.pm.in=.pm)

G1MANPAGES = $(GALLMODULES:.pm=.1man)

PERLCRITIC_PM = $(GALLMODULES)

man1_MANS = $(G1MANPAGES)

dist_noinst_DATA = $(ALLMODULES)

test: $(GALLMODULES)
	prove $(PERLINCLUDE) -v t/

README.md: Apache2/Upload/Progress.pm
	$(POD2MARKDOWN) $< > $@

all: README.md

CLEANFILES = $(GALLMODULES) $(GPERLCRITIC_PM)

.PHONY: clean-local
clean-local:
	$(MAKE) clean-generated-man-pages
	find . -name '*.log' -exec rm {} \; || true

.PHONY: clean-generated-man-pages
clean-generated-man-pages:
	for mpath in $(G1MANPAGES); do \
	echo "$${mpath}"; \
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

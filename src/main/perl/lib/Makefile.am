SUBDIRS = .

include $(top_srcdir)/includes/directories.inc
include $(top_srcdir)/includes/perl-build.inc
include $(top_srcdir)/includes/perl-modules.inc
include $(top_srcdir)/includes/perlcritic.inc

GALLMODULES = $(ALLMODULES:.pm.in=.pm)

PERLCRITIC_MODULES = $(GALLMODULES)

perlrun = @PERL@

if RPM_BUILD_MODE
perlwc = \# 
else
perlwc = @PERL@
endif

# you should be using perl5libdir as the base target of your perl
# modules, not as simply part of your PERLINCLUDE
ax_perl5_extra_includes_opt = @ax_perl5_extra_includes_opt@
ax_perl5_extra_includes = @ax_perl5_extra_includes@

dist_noinst_DATA = $(ALLMODULES)

G1MANPAGES = $(GALLMODULES:.pm=.1man)

man1_MANS = $(G1MANPAGES)

@do_subst_command@

if USING_PERL5_EXTRA_INCLUDES
PERL5_EXTRA_INCLUDES = $(ax_perl5_extra_includes_opt)
else
endif

# Please see the notes concerning PERLINCLUDE in the ../bin/Makefile.am file
PERLINCLUDE = \
    -I $(builddir) \
    -I $(builddir)/../lib \
    $(PERL5_EXTRA_INCLUDES) \
    -I $(perl5libdir)

# pattern rules
%.pm: %.pm.in
	test -d "$$(dirname "$@")" || $(INSTALL) -d "$$(dirname "$@")"
	$(do_subst) $< > $@
	>2& echo "$@"
	$(perlwc) -wc $(PERLINCLUDE)  -M$$(echo $@ | perl -np -e 's/\//\:\:/g; s/\.pm$$//;') -e 1 || { rm $@ && exit 1; }

test: $(GALLMODULES)
	prove -v t/

PERLCRITIC_PM = $(GALLMODULES)

all:

CLEANFILES = $(GALLMODULES) $(GPERLCRITIC_PM)

$(G1MANPAGES): %.1man : %.pm
	target_name="$@";\
	tname=$$(echo "$${target_name}" | sed -e 's/\.1man$$//') ;\
	"$(POD2MAN)"  $< \
	--center="$(PACKAGE)" \
	--name="$${tname}" \
	--release=$(PACKAGE)-$(VERSION) \
	--section=1man > "$${target_name}" || true

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

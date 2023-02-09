SUBDIRS = .

include $(top_srcdir)/includes/directories.inc
include $(top_srcdir)/includes/perlcritic.inc
include $(top_srcdir)/includes/perl-build.inc

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

# this is where we will install perl scripts
libexecdir = @libexecdir@

PERLSCRIPTS =

GPERLSCRIPTS = $(PERLSCRIPTS:.pl.in=.pl)

ALLSCRIPTS = \
    $(GPERLSCRIPTS)

G1MANPAGES = \
    $(GPERLSCRIPTS:.pl=.1man)

# list the files you want perlcritic to check (make check)
PERLCRITIC_PL = $(GPERLSCRIPTS)
PERLCRITIC_PM = 

libexec_SCRIPTS = \
    $(GPERLSCRIPTS)

dist_noinst_DATA = \
    $(PERLSCRIPTS)

man1_MANS = $(G1MANPAGES)

@do_subst_command@

if USING_PERL5_EXTRA_INCLUDES
PERL5_EXTRA_INCLUDES = $(ax_perl5_extra_includes_opt)
else
endif

PERLINCLUDE = \
    -I $(builddir) \
    -I $(builddir)/../lib \
    $(PERL5_EXTRA_INCLUDES) \
    -I $(perl5libdir)

$(GPERLSCRIPTS): % : %.in
	$(BUILD_PERL_RULE)

.PHONY: test
test: $(GPERLSCRIPTS)
	test -d t/ && PERL5LIB=../lib prove -v t/

all:

CLEANFILES = \
    $(GPERLSCRIPTS) \
    $(GPERLCRITIC_PL)

define BUILD_MAN_PAGE_RULE
	target_name="$@" ;\
	tname=$$(echo "$${target_name}" | sed -e 's/\.1man$$//') ;\
	"$(POD2MAN)" $< \
	--center="$(PACKAGE)" \
	--name="$${tname}" \
	--release=$(PACKAGE)-$(VERSION) \
	--section=1man > "$${target_name}" || true
endef

$(G1MANPAGES): %.1man : %.pl
	$(BUILD_MAN_PAGE_RULE)

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

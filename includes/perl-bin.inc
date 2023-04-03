# -*- mode: makefile; -*-
# This is a Makefile rule use tabs!

perlrun = $(PERL)

if RPM_BUILD_MODE
perlwc = \# 
else
perlwc = $(perlrun)
endif

@do_subst_command@

# colon separated list extra paths 
ax_perl5_extra_includes  = @ax_perl5_extra_includes@

# contains a list of paths of form -I {path} derived from above
# use in PERLINCLUDE below
ax_perl5_extra_includes_opt = @ax_perl5_extra_includes_opt@

if USING_PERL5_EXTRA_INCLUDES
PERL5_EXTRA_INCLUDES = $(ax_perl5_extra_includes_opt)
else
endif

PERLINCLUDE = \
    -I $(builddir) \
    -I $(builddir)/../lib \
    $(PERL5_EXTRA_INCLUDES) \
    -I $(perl5libdir)

%.pm: %.pm.in
	test -d "$$(dirname "$@")" || $(INSTALL) -d "$$(dirname "$@")"
	$(do_subst) $< > $@
	>&2 echo "$@"
	$(perlwc) -wc $(PERLINCLUDE)  -M$$(echo $@ | perl -np -e 's/\//\:\:/g; s/\.pm$$//;') -e 1 || { rm $@ && exit 1; }

%.pl: %.pl.in
	test -d "$$(dirname "$@")" || $(INSTALL) -d "$$(dirname "$@")"
	$(do_subst) $< > $@
	>&2 echo "WARNING: $@"
	$(perlwc) -wc $(PERLINCLUDE) $@ || { rm $@ && exit 1; }

.cgi: %.pl
	cp $< $$(basename).cgi

define MAN_PAGE_BUILD_RECIPE
	target_name="$@";\
	tname=$$(echo "$${target_name}" | sed -e 's/\.1man$$//') ;\
	"$(POD2MAN)"  $< \
	--center="$(PACKAGE)" \
	--name="$${tname}" \
	--release=$(PACKAGE)-$(VERSION) \
	--section=1man > "$${target_name}" || true
endef

man1_MANS = $(G1MANPAGES)

%.1man : %.pm
	$(MAN_PAGE_BUILD_RECIPE)

%.1man : %.pl
	$(MAN_PAGE_BUILD_RECIPE)

%.1man : %.cgi
	$(MAN_PAGE_BUILD_RECIPE)

%.md : %.pm
	$(POD2MARKDOWN) < $< >$@

libexecdir = @libexecdir@

libexec_SCRIPTS = 
    $(GPERLSCRIPTS)

PERLCRITIC_PL = \
    $(GPERLSCRIPTS)

PERLSCRIPTS = 

GPERLSCRIPTS = $(PERLSCRIPTS:.pl.in=.pl)

ALLSCRIPTS = \
    $(GPERLSCRIPTS)

G1MANPAGES = \
    $(GPERLSCRIPTS:.pl=.1man)

dist_noinst_DATA = \
    $(PERLSCRIPTS)

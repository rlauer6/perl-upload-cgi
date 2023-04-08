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
ax_perl5_extra_includes  = $(ax_perl5_extra_includes)

# contains a list of paths of form -I {path} derived from above
# use in PERLINCLUDE below
ax_perl5_extra_includes_opt = $(ax_perl5_extra_includes_opt)

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

define MAN_PAGE_BUILD_RECIPE
	target_name="$@";\
	tname=$$(echo "$${target_name}" | sed -e 's/\.1man$$//') ;\
	"$(POD2MAN)"  $< \
	--center="$(PACKAGE)" \
	--name="$${tname}" \
	--release=$(PACKAGE)-$(VERSION) \
	--section=1man > "$${target_name}" || true
endef

%.1man : %.pm
	$(MAN_PAGE_BUILD_RECIPE)

%.1man : %.pl
	$(MAN_PAGE_BUILD_RECIPE)

%.1man : %.cgi
	$(MAN_PAGE_BUILD_RECIPE)

%.md : %.pm
	$(POD2MARKDOWN) < $< >$@

# +--------------------------------------------+
# | .                                          |
# +--------------------------------------------+

PERLMODULES = 

GPERLMODULES = $(PERLMODULES:.pm.in=.pm)

# +--------------------------------------------+
# | Workflow                                   |
# +--------------------------------------------+

WORKFLOWMODULES = 

GWORKFLOWMODULES = $(WORKFLOWMODULES:.pm.in=.pm)

perl5lib_workflowdir = $(perl5libdir)/Workflow
perl5lib_workflow_DATA = $(GWORKFLOWMODULES)

# +--------------------------------------------+
# | Apache2/Upload                             |
# +--------------------------------------------+

APACHE2UPLOADMODULES = \
    Apache2/Upload/Progress.pm.in

GAPACHE2UPLOADMODULES = $(APACHE2UPLOADMODULES:.pm.in=.pm)

$(GAPACHE2UPLOADMODULES): $(GAPACHE2UPLOADPROGRESSMODULES)

perl5lib_apache2uploaddir = $(perl5libdir)/Apache2/Upload

perl5lib_apache2upload_DATA = $(GAPACHE2UPLOADMODULES)

# +--------------------------------------------+
# | Apache2/Upload/Prorgress                   |
# +--------------------------------------------+

APACHE2UPLOADPROGRESSMODULES = \
    Apache2/Upload/Progress/Redis.pm.in

GAPACHE2UPLOADPROGRESSMODULES = $(APACHE2UPLOADPROGRESSMODULES:.pm.in=.pm)

perl5lib_apache2uploadprogressdir = $(perl5libdir)/Apache2/Upload/Progress

perl5lib_apache2uploadprogress_DATA = $(GAPACHE2UPLOADPROGRESSMODULES)

# +--------------------------------------------+
# | Workflow/S3                                |
# +--------------------------------------------+

WORKFLOWS3MODULES = \
    Workflow/S3/Uploader.pm.in

GWORKFLOWS3MODULES = $(WORKFLOWS3MODULES:.pm.in=.pm)

perl5lib_workflows3dir = $(perl5libdir)/Workflow/S3
perl5lib_workflows3_DATA = $(GWORKFLOWS3MODULES)

ALLMODULES = \
    $(PERLMODULES) \
    $(WORKFLOWMODULES) \
    $(WORKFLOWS3MODULES) \
    $(APACHE2UPLOADMODULES) \
    $(APACHE2UPLOADPROGRESSMODULES)

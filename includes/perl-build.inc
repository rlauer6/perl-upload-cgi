# -*- mode: makefile; -*-
# This is a Makefile rule use tabs!
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

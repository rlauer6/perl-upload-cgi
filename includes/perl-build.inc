# -*- mode: makefile; -*-
# This is a Makefile rule use tabs!
define BUILD_PERL_RULE
	test -d "$$(dirname "$@")" || $(INSTALL) -d "$$(dirname "$@")"
	$(do_subst) $< > $@
	>&2 echo "WARNING: $@"
	$(perlwc) -wc $(PERLINCLUDE) $@ || { rm $@ && exit 1; }
endef

define BUILD_PERL_MODULE_RULE
	test -d "$$(dirname "$@")" || $(INSTALL) -d "$$(dirname "$@")"
	$(do_subst) $< > $@
	>&2 echo "WARNING: $@"
	$(perlwc) -wc $(PERLINCLUDE) -M$$(echo $@ | $(perlwc) -np -e 's/\//\:\:/g; s/\.pm$$//;') -e 1 || { rm $@ && exit 1; }
endef

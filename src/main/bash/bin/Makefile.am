SUBDIRS = . 

perlrun = @PERL@
bashrun = @BASHRUN@

BASHSCRIPTS = 

GBASHSCRIPTS = $(BASHSCRIPTS:.in=)

bin_SCRIPTS = $(GBASHSCRIPTS)

dist_noinst_DATA = $(BASHSCRIPTS)

@do_subst_command@

$(GBASHSCRIPTS): % : %.in
	$(do_subst) $< > $@

CLEANFILES = $(GBASHSCRIPTS)

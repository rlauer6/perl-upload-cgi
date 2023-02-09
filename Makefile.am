#-*- mode: makefile-gmake; -*-

SUBDIRS = . src config resources

ACLOCAL_AMFLAGS = -I autotools

dist_noinst_DATA =  \
    README.md \
    ChangeLog

# These are automatically added to the distribution since automake
# needs them to create the Makefile.in

#    includes/perl-build.inc \
#    includes/perlcritic.inc \
#    includes/directories.inc \
#    includes/apache-directories.inc

CLEANFILES = 

all:

# install CPAN dependencies
.PHONY: cpan
cpan:
	mkdir -p $(abs_builddir)/cpan
	for a in $$(cat requirements.txt); do \
	  cpanm -i -L $(abs_builddir)/cpan -n $$a; \
	done

.PHONY: test
test:
	$(MAKE) clean
	$(MAKE)
	cd $(top_srcdir)/src/main/perl/bin && make test
	cd $(top_srcdir)/src/main/perl/lib && make test

$(PACKAGE)-$(VERSION).tar.gz:
	$(MAKE) dist

clean-local:
	test -d rpm && rm -rf rpm || true
	test -d cpan && rm -rf cpan || true
	rm -f *.tar.gz || true

DISTCHECK_CONFIGURE_FLAGS = --disable-perlcritic-mode

#distcleancheck:
#	@:
#
#distcleancheck_listfiles = \
#  find . -type f -exec sh -c 'test -f $(srcdir)/$$1 || echo $$1' \
#       sh '{}' ';'
#distcheck-hook:
#	rm $(abs_builddir)/includes/perl-modules.inc

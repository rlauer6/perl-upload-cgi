# -*- mode: makefile; -*-
# perlcritic test for .pl, .pm and .cgi files
#
# set PERLCRITIC_(PL|PM|CGI) to the files you want to check
#
# make check
# make check CHECK_ALL=1 (to continue on errors)

# outputs .pc files (OK) or ,.pc.log files with issues
perlcritic = @PERLCRITIC@

PERLCRITIC_THEME = 'security||certrule||freenode'
PERLCRITIC_SEVERITY = 1
PERLCRITIC_VERBOSITY = 9
PERLCRITICRC = $(top_srcdir)/perlcriticrc

PERLCRITIC_OPTIONS = \
    --profile $(PERLCRITICRC) \
    --force \
    --theme $(PERLCRITIC_THEME) \
    --severity $(PERLCRITIC_SEVERITY) \
    --verbose $(PERLCRITIC_VERBOSITY)

GPERLCRITIC_PM = $(PERLCRITIC_PM:.pm=.pc)

GPERLCRITIC_PL = $(PERLCRITIC_PL:.pl=.pc)

GPERLCRITIC_CGI = $(PERLCRITIC_CGI:.cgi=.pc)

PERLCRITIC_ALL = \
    $(PERLCRITIC_PM) \
    $(PERLCRITIC_PL) \
    $(PERLCRITIC_CGI)

GPERLCRITIC_ALL = \
    $(GPERLCRITIC_PM) \
    $(GPERLCRITIC_PL) \
    $(GPERLCRITIC_CGI)

if PERLCRITIC_MODE_ENABLED
check:	$(GPERLCRITIC_ALL)

define BUILD_PERLCRITIC_RULE
	set -o pipefail; \
	LOGFILE="$$(dirname $@)/$$(basename $@ .$$EXT).log"; \
	if $(perlcritic) $(PERLCRITIC_OPTIONS) $< 2>&1 | tee $$LOGFILE; then \
	  mv $$LOGFILE $@; \
	else \
	  echo "check all $(CHECK_ALL)"; \
	  test -n "$(CHECK_ALL)" && true; \
	fi
endef

$(GPERLCRITIC_PM): %.pc : %.pm $(PERLCRITIC_PM)
	EXT=pm; \
	$(BUILD_PERLCRITIC_RULE)

$(GPERLCRITIC_PL): %.pc : %.pl $(PERLCRITIC_PL)
	EXT=pl; \
	$(BUILD_PERLCRITIC_RULE)

$(GPERLCRITIC_CGI): %.pc : %.cgi $(PERLCRITIC_CGI)
	EXT=cgi; \
	$(BUILD_PERLCRITIC_RULE)
endif

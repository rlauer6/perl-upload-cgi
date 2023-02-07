INSTALL_DIR    = $$HOME/www

INCLUDE_DIR    = $(INSTALL_DIR)/include
JAVASCRIPT_DIR = $(INSTALL_DIR)/html/javascript
CGI_BIN_DIR    = $(INSTALL_DIR)/cgi-bin
CONFIG_DIR     = $(INSTALL_DIR)/config

CONFIG_FILES = \
    config/upload.json

JAVASCRIPT_FILES = \
    src/main/javascript/upload.js

INCLUDE_FILES = \
    resources/templates/upload-form.tt

CGI_BIN_FILES = \
    src/main/perl/cgi-bin/upload.cgi

PERL_FILES = \
    src/main/perl/cgi-bin/upload.pl

$(CGI_BIN_FILES): $(PERL_FILES)
	perl -wc $<
	cp $< $@

install: $(CGI_BIN_FILES)
	echo $$HOME;
	if test -z "$$HOME"; then \
	  >&2 echo "no home set"; \
	  false; \
	fi

	for a in $(CGI_BIN_FILES); do \
	  install -D $$a $(CGI_BIN_DIR)/$$(basename $$a); \
	done

	for a in $(CONFIG_FILES); do \
	  install -D $$a $(CONFIG_DIR)/$$(basename $$a); \
	done

	for a in $(JAVASCRIPT_FILES); do \
	  install -D $$a $(JAVASCRIPT_DIR)/$$(basename $$a); \
	done

	for a in $(INCLUDE_FILES); do \
	  install -D $$a $(INCLUDE_DIR)/$$(basename $$a); \
	done

clean:
	rm $(CGI_BIN_FILES)

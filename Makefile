.PHONY: test doc

default: install doc

install: install_bin install_doc

install_bin:
	install bin/envy /usr/local/bin
	mkdir -p /usr/local/bin/envy.lib/
	install bin/envy.lib/* /usr/local/bin/envy.lib/

install_doc:
	mkdir -p /usr/local/share/man/man1/
	[ -f doc/envy.1 ] && install doc/*.1 /usr/local/share/man/man1/ || true

# test:
# 	test/roundup test/*-test.sh

doc: doc/envy.1

doc/envy.1: README.md
	@mkdir -p doc
	@which -s ronn || (echo "Please install ronn: gem install ronn" && false)
	ronn --pipe --roff README.md > doc/envy.1
	ronn --pipe --html README.md > doc/envy.1.html

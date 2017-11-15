.PHONY: test doc

install: doc/envy.1
	install bin/envy /usr/local/bin
	mkdir -p /usr/local/bin/envy.lib/
	install bin/envy.lib/* /usr/local/bin/envy.lib/
	# install doc/*.1 /usr/local/share/man/man1/

# test:
# 	test/roundup test/*-test.sh

doc/envy.1: README.md
	@mkdir -p doc
	@which -s ronn || (echo "Please install ronn: gem install ronn" && false)
	ronn --pipe --roff README.md > doc/envy.1
	ronn --pipe --html README.md > doc/envy.1.html

.PHONY: doc

default: build-golang
#default: test-ruby install doc

test: test-ruby

# -- go specific --------------------------------------------------------------

.PHONY: bin/envy.go.bin
build-golang: bin/envy.go.bin

bin/envy.go.bin:
	go build -o $@ src/envy/main.go

test-golang:
	ENVY=bin/envy.go spec/bin/roundup spec/*-test.sh

# --- ruby specific -----------------------------------------------------------

test-ruby:
	ENVY=bin/envy spec/bin/roundup spec/*-test.sh

# --- generic -----------------------------------------------------------------

install: install_bin install_doc

install_bin:
	install bin/envy /usr/local/bin

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

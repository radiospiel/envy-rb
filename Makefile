.PHONY: doc

default: build-golang
#default: test-ruby install doc

test: test-ruby

# -- go specific --------------------------------------------------------------

.PHONY: bin/envy.go.bin
build-golang: bin/envy.go.bin

bin/envy.go.bin:
	go build -o $@ src/golang/main.go

test-golang:
	ENVY=bin/envy.go spec/bin/roundup spec/*-test.sh

build-golang-all:
	# $MACHTYPE | $GOOS | $GOARCH
	#
	# x86_64-apple-darwin18 | darwin | amd64
	# x86_64-pc-linux-gnu | linux | amd64
	GOOS=darwin GOARCH=amd64 go build -ldflags="-s -w" -o bin/envy.x86_64-apple-darwin18.bin src/golang/main.go
	upx bin/envy.x86_64-apple-darwin18.bin
	GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o bin/envy.x86_64-pc-linux-gnu.bin src/golang/main.go
	upx bin/envy.x86_64-pc-linux-gnu.bin

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

.PHONY: doc

# we currently don't need MACHTYPE
# MACHTYPE:=$(shell set | grep ^MACHTYPE= | sed s-.*=--)

default: build-golang

test: build-golang test-golang

# -- go specific --------------------------------------------------------------

.PHONY: bin/envy.go.bin
build-golang: bin/envy.go.bin

bin/envy.go.bin: .dependencies
	go build -o $@ src/golang/main.go

test-golang:
	ENVY=bin/envy.go spec/bin/roundup spec/*-test.sh

.dependencies: Makefile
	go get github.com/spf13/cobra
	touch .dependencies

# --- releases ----------------------------------------------------------------

# builds and packs binaries for all supported platforms
#
# $MACHTYPE                | $GOOS  | $GOARCH
#
# x86_64-apple-darwin18    | darwin | amd64
# x86_64-pc-linux-gnu      | linux  | amd64
#
build-golang-all: .dependencies
	GOOS=darwin GOARCH=amd64 go build -ldflags="-s -w" -o bin/envy.x86_64-apple-darwin18.bin src/golang/main.go
	upx bin/envy.x86_64-apple-darwin18.bin
	GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o bin/envy.x86_64-pc-linux-gnu.bin src/golang/main.go
	upx bin/envy.x86_64-pc-linux-gnu.bin

prerelease: build-golang-all
	scripts/prerelease

release: build-golang-all
	scripts/release

# --- ruby specific -----------------------------------------------------------

test-ruby:
	ENVY=bin/envy.rb spec/bin/roundup spec/*-test.sh

# --- local installation ------------------------------------------------------

install: bin/envy.go.bin
	install bin/envy.go.bin /usr/local/bin/envy
	mkdir -p /usr/local/share/man/man1/
	[ -f doc/envy.1 ] && install doc/*.1 /usr/local/share/man/man1/ || true

doc: doc/envy.1

doc/envy.1: README.md
	@mkdir -p doc
	@which -s ronn || (echo "Please install ronn: gem install ronn" && false)
	ronn --pipe --roff README.md > doc/envy.1
	ronn --pipe --html README.md > doc/envy.1.html

#!/usr/bin/env roundup
set -eu -o pipefail


describe "envy generate"

before() {
  rm -rf tmp/spec/*
}

it_is_listed_in_help() {
  ($ENVY help 2>&1) | grep -w generate
}

it_generates_a_file() {
  EDITOR=true ENVY_SECRET_PATH=spec/fixtures/secret $ENVY generate tmp/spec/envy
  test -f tmp/spec/envy
}

it_does_not_touch_an_existing_file() {
  touch tmp/spec/envy
  cp tmp/spec/envy tmp/spec/envy.orig
  ! EDITOR=true ENVY_SECRET_PATH=spec/fixtures/secret bin/envy.go generate tmp/spec/envy
  diff tmp/spec/envy tmp/spec/envy.orig
}

it_does_not_generates_a_file_without_a_secret() {
  ! EDITOR=true ENVY_SECRET_PATH=spec/fixtures/config.no-secret $ENVY generate tmp/spec/envy.config
  ! test -f tmp/spec/envy.config
}

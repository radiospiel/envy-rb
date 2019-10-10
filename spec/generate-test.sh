#!/usr/bin/env roundup

describe "envy generate"

before() {
  rm -rf tmp/spec/*
}

it_is_listed_in_help() {
  (bin/envy help 2>&1) | grep -w generate
}

it_generates_a_file() {
  EDITOR=true ENVY_SECRET_PATH=spec/fixtures/secret bin/envy generate tmp/spec.envy
  test -f tmp/spec.envy
}

it_does_not_generates_a_file_without_a_secret() {
  ! EDITOR=true ENVY_SECRET_PATH=spec/fixtures/config.no-secret bin/envy generate tmp/spec/envy.config
  ! test -f tmp/spec/envy.config
}

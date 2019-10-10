#!/usr/bin/env roundup

describe "envy template"

before() {
  rm -rf tmp/spec/*
}

it_is_listed_in_help() {
  ($ENVY help 2>&1) | grep -w template
}

it_fills_in_template() {
  ENVY_SECRET_PATH=spec/fixtures/secret $ENVY template spec/fixtures/config spec/template-test.sh.in1 > tmp/spec/stdout
  diff spec/template-test.sh.out1 tmp/spec/stdout
}

it_errs_with_missing_setting() {
  ! ENVY_SECRET_PATH=spec/fixtures/secret $ENVY template spec/fixtures/config spec/template-test.sh.in2
}

it_fills_in_from_env() {
  UNKNOWN=unknown ENVY_SECRET_PATH=spec/fixtures/secret $ENVY template spec/fixtures/config spec/template-test.sh.in2 > tmp/spec/stdout
  diff spec/template-test.sh.out3 tmp/spec/stdout
}

it_fills_in_default() {
  ENVY_SECRET_PATH=spec/fixtures/secret $ENVY template spec/fixtures/config spec/template-test.sh.in4 > tmp/spec/stdout
  diff spec/template-test.sh.out4 tmp/spec/stdout
}

#!/usr/bin/env roundup
set -eu -o pipefail


describe "envy secret:generate"

before() {
  rm -rf tmp/spec/*
}

it_is_listed_in_help() {
  ($ENVY help 2>&1) | grep -w secret:generate
}

it_generates_a_32_byte_secret() {
  ENVY_SECRET_PATH=tmp/spec/envy.secret $ENVY secret:generate

  # secret file has 32 byte
  test 32 -eq $(cat tmp/spec/envy.secret | wc -c)

  # secret file is 0400
  test '-r--------' == $(ls -l tmp/spec/envy.secret | awk '{ print $1 }')
}

it_does_not_overwrite_a_secret() {
  touch tmp/spec/envy.secret

  # must fail
  ! ENVY_SECRET_PATH=tmp/spec/envy.secret $ENVY secret:generate

  # must not change the (empty) secret file
  test 0 -eq $(cat tmp/spec/envy.secret | wc -c)
}

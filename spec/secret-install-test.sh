#!/usr/bin/env roundup
set -eu -o pipefail


describe "envy secret:install"

before() {
  rm -rf tmp/spec/*
}

it_is_listed_in_help() {
  ($ENVY help 2>&1) | grep -w secret:install
}

it_installs_the_secret() {
  SSH=false ENVY_SECRET_PATH=tmp/spec/envy.secret $ENVY secret:install target@system

  test 1 == 2
  # # secret file has 32 byte
  # test 32 -eq $(cat tmp/spec/envy.secret | wc -c)
  #
  # # secret file is 0400
  # test '-r--------' == $(ls -l tmp/spec/envy.secret | awk '{ print $1 }')
}

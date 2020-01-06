#!/usr/bin/env roundup
set -eu -o pipefail


describe "envy secret:install"

before() {
  rm -rf tmp/spec/*
}

it_is_listed_in_help() {
  ($ENVY help 2>&1) | grep -w secret:install
}

it_runs_scp_and_fails() {
  ! ENVY_SECRET_PATH=spec/fixtures/secret $ENVY secret:install target@no-such-host
}

it_fails_if_scp_fails() {
  ! SCP=false ENVY_SECRET_PATH=spec/fixtures/secret $ENVY secret:install target@no-such-host
}

it_runs_scp_w_expected_args() {
  SCP=spec/fixtures/log-args ENVY_SECRET_PATH=spec/fixtures/secret $ENVY secret:install target@no-such-host

  # The args.log file contains the arguments that $SCP received
  echo "spec/fixtures/secret target@no-such-host:.secret.envy" > tmp/spec/args.log.orig
  diff tmp/spec/args.log tmp/spec/args.log.orig
}

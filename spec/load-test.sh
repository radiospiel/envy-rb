#!/usr/bin/env roundup

# this spec tests values in fixtures.envy
describe "envy load"

before() {
  rm -rf tmp/spec/*
}

it_is_listed_in_help() {
  (bin/envy help 2>&1) | grep -w load
}

it_loads_envy_file() {
  ENVY_SECRET_PATH=spec/fixtures/secret bin/envy load spec/fixtures/config | sort > tmp/spec/stdout
  diff tmp/spec/stdout spec/load-test.sh.out1
}

it_loads_envy_file_w_export_flag() {
  ENVY_SECRET_PATH=spec/fixtures/secret bin/envy load --export spec/fixtures/config | sort > tmp/spec/stdout
  diff tmp/spec/stdout spec/load-test.sh.out2
}

it_loads_envy_file_w_json_flag() {
  # jq pretty prints JSON.
  ENVY_SECRET_PATH=spec/fixtures/secret bin/envy load --json spec/fixtures/config | jq | sort > tmp/spec/stdout
  diff tmp/spec/stdout spec/load-test.sh.out3
}

it_fails_with_missing_secret() {
  ! ENVY_SECRET_PATH=spec/fixtures/missing-secret bin/envy load spec/fixtures/config > tmp/spec/stdout
  ! diff tmp/spec/stdout spec/load-test.sh.out1
}

it_fails_with_wrong_secret() {
  ! ENVY_SECRET_PATH=spec/fixtures/invalid-secret bin/envy load spec/fixtures/config > tmp/spec/stdout
  ! diff tmp/spec/stdout spec/load-test.sh.out1
}

it_fails_with_nonsense_secret() {
  ! ENVY_SECRET_PATH=spec/fixtures/nonsense-secret bin/envy load spec/fixtures/config > tmp/spec/stdout
  ! diff tmp/spec/stdout spec/load-test.sh.out1
}

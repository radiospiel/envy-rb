#!/usr/bin/env roundup
set -eu -o pipefail


# this spec tests values in fixtures.envy
describe "envy edit"

before() {
  rm -rf tmp/spec/*

  cp spec/fixtures/config tmp/spec/config
  cp spec/fixtures/config tmp/spec/config.orig
}

it_is_listed_in_help() {
  ($ENVY help 2>&1) | grep -w edit
}

it_edits_envy_file_via_EDITOR() {
  # 1. must signal success
  EDITOR=spec/edit-test.sh.editor-success ENVY_SECRET_PATH=spec/fixtures/secret $ENVY edit tmp/spec/config

  # 2. must change file
  ! diff tmp/spec/config tmp/spec/config.orig

  # 3. must have specific content
  ENVY_SECRET_PATH=spec/fixtures/secret $ENVY load tmp/spec/config | sort > tmp/spec/stdout
  diff tmp/spec/stdout spec/edit-test.sh.out1
}

it_does_not_change_envy_file_if_editor_fails() {
  # 1. must signal failure
  ! EDITOR=spec/edit-test.sh.editor-fail ENVY_SECRET_PATH=spec/fixtures/secret $ENVY edit tmp/spec/config

  # 2. must not change file at all
  diff tmp/spec/config  tmp/spec/config.orig
}


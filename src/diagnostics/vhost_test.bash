#!/usr/bin/env bash

[[ $DEBUG = true ]] && set -x

TEST="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# basht macro, shellcheck fix
export T_fail

# shellcheck disable=SC1090
source $TEST/test_helpers

# shellcheck disable=SC1090
source $TEST/store_helpers

T_AllSnapshotVhostsStillExist() {
  if store_vhosts_exists; then
    for vhost in $(store_vhosts)
    do
      expect_to_contain  "$(rabbitmq_vhosts)" "$vhost"  || $T_fail
    done
  else
    echo "There is no snapshot vhosts in store"
  fi
}

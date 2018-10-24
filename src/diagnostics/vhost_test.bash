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
    local actual_vhosts expected_vhosts

    actual_vhosts=$(rabbitmq_vhosts)
    expected_vhosts=$(store_vhosts)

    for vhost in $expected_vhosts
    do
      expect_to_contain  "$actual_vhosts" "$vhost"  || $T_fail
    done
    echo "All snapshot vhosts still exist"

    [ "$(echo $actual_vhosts | wc -w)" -le "$(echo $expected_vhosts | wc -w)" ] || echo "There are more vhosts than previous snapshot"

  else
    echo "There is no snapshot vhosts in store"
  fi
}

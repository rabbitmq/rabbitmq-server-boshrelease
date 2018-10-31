#!/usr/bin/env bash

[[ $DEBUG = true ]] && set -x

TEST="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# basht macro, shellcheck fix
export T_fail

# shellcheck disable=SC1090
source $TEST/../test_helpers

# shellcheck disable=SC1090
source $TEST/../rabbitmq_helpers

T_AllSnapshotVhostsStillExist() {
  if store_exists; then
    local missing_vhosts
    missing_vhosts="$(comm -23 <(store_vhosts) <(rabbitmq_vhosts))"
    [[ -z $missing_vhosts ]] || $T_fail "There are missing vhost : $missing_vhosts"
    echo "All snapshot vhosts still exist"

    [ "$(rabbitmq_vhosts | wc -l)" -le "$(store_vhosts | wc -l)" ] || echo "There are more vhosts than previous snapshot"

  else
    echo "There are no snapshot in store"
  fi
}

#T_AllSnapshotVhostsLimitsStillExist() {
# vhost limits are stored as parameters check T_AllSnapshotsParametersStillExist
#}

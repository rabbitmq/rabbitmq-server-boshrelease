#!/usr/bin/env bash

[[ $DEBUG = true ]] && set -x

TEST="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# basht macro, shellcheck fix
export T_fail

# shellcheck disable=SC1090
source $TEST/../test_helpers

# shellcheck disable=SC1090
source $TEST/../rabbitmq_helpers


T_AllSnapshotPoliciesStillExist() {
  local missing_policies
  missing_policies="$(comm -23 <(store_policies) <(rabbitmq_policies) | tr '\n' ' ')"
  [[ -z $missing_policies ]] || $T_fail "There are missing policies : $missing_policies"
}

#T_AllSnapshotOperatorPoliciesStillExist() {
# Operator policies are stored as parameters. check T_AllSnapshotParametersStillExist
#}

T_AllSnapshotParametersStillExist() {
  local missing_parameters
  missing_parameters="$(comm -23 <(store_parameters) <(rabbitmq_parameters)  | tr '\n' ' ')"
  [[ -z $missing_parameters ]] || $T_fail "There are missing parameters : $missing_parameters"
}

T_AllSnapshotGlobalParametersStillExist() {
  local missing_global_parameters
  missing_global_parameters=$(comm -23 <(store_global_parameters) <(rabbitmq_global_parameters))
  [[ -z $missing_global_parameters ]] || $T_fail "There are missing global parameters: $missing_global_parameters"
}

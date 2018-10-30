#!/usr/bin/env bash

[[ $DEBUG = true ]] && set -x

TEST="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# basht macro, shellcheck fix
export T_fail

# shellcheck disable=SC1090
source $TEST/../test_helpers

# shellcheck disable=SC1090
source $TEST/../store_helpers

# shellcheck disable=SC1090
source $TEST/../rabbitmq_helpers


T_AllSnapshotPoliciesStillExist() {
  local missing_policies
  for vhost in $(store_vhosts)
  do
    local vhost_missing_policies
    vhost_missing_policies="$(comm -23 <(store_policies $vhost) <(rabbitmq_policies $vhost) | awk '{ print $1 }' | tr '\n' ' ')"
    [[ -z $vhost_missing_policies ]] || missing_policies+="{ $vhost :: $vhost_missing_policies } , "
  done
  [[ -z $missing_policies ]] || $T_fail "There are missing policies { vhost :: user } : $missing_policies"
}

T_AllSnapshotOperatorPoliciesStillExist() {
  local missing_policies
  for vhost in $(store_vhosts)
  do
    local vhost_missing_policies
    vhost_missing_policies="$(comm -23 <(store_operator_policies $vhost) <(rabbitmq_operator_policies $vhost) | awk '{ print $1 }' | tr '\n' ' ')"
    [[ -z $vhost_missing_policies ]] || missing_policies+="{ $vhost :: $vhost_missing_policies } , "
  done
  [[ -z $missing_policies ]] || $T_fail "There are missing operator policies { vhost :: user } : $missing_policies"
}

T_AllSnapshotParametersStillExist() {
  local missing_parameters
  for vhost in $(store_vhosts)
  do
    local vhost_missing_parameters
    vhost_missing_parameters="$(comm -23 <(store_parameters $vhost) <(rabbitmq_parameters $vhost) | awk '{ print $1 }' | tr '\n' ' ')"
    [[ -z $vhost_missing_parameters ]] || missing_parameters+="{ $vhost :: $vhost_missing_parameters } , "
  done
  [[ -z $missing_parameters ]] || $T_fail "There are missing parameters { vhost :: user } : $missing_parameters"
}

T_AllSnapshotGlobalParametersStillExist() {
  local missing_global_parameters

  missing_global_parameters=$(comm -23 $DIAGNOSTICS_GLOBAL_PARAMETERS_SNAPSHOT <(rabbitmq_global_parameters))
  [[ -z $missing_global_parameters ]] || $T_fail "There are missing global parameters: $missing_global_parameters"
}

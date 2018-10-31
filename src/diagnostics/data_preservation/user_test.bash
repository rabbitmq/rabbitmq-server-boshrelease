#!/usr/bin/env bash

[[ $DEBUG = true ]] && set -x

TEST="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# basht macro, shellcheck fix
export T_fail

# shellcheck disable=SC1090
source $TEST/../test_helpers

# shellcheck disable=SC1090
source $TEST/../rabbitmq_helpers

T_AllSnapshotUserTagsStillExist() {
  local missing_users
  missing_users=$(comm -23 <(store_users) <(rabbitmq_users))
  [[ -z $missing_users ]] || $T_fail "There are missing users: $missing_users"
}
T_AllSnapshotUserPermissionsStillExist() {
  local missing_permissions
  missing_permissions="$(comm -23 <(store_permissions) <(rabbitmq_permissions) | awk '{ print $1 }' | tr '\n' ' ')"
  [[ -z $missing_permissions ]] || $T_fail "There are missing user permissions : $missing_permissions"
}
T_AllSnapshotUserTopicPermissionsStillExist() {
  local missing_topic_permissions
  missing_topic_permissions="$(comm -23 <(store_topic_permissions) <(rabbitmq_topic_permissions) | awk '{ print $1"-"$2 }' | tr '\n' ' ')"
  [[ -z $missing_topic_permissions ]] || $T_fail "There are missing user topic permissions  : $missing_topic_permissions"
}

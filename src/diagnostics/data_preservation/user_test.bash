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

AllSnapshotUserTagsStillExist() {
  local missing_users

  missing_users=$(comm -23 $DIAGNOSTICS_USERS_SNAPSHOT <(rabbitmq_users))
  [[ -z $missing_users ]] || $T_fail "There are missing users: $missing_users"
}
AllSnapshotUserPermissionsStillExist() {
  local missing_permissions
  for vhost in $(store_vhosts)
  do
    local vhost_missing_permissions
    vhost_missing_permissions="$(comm -23 <(store_permissions $vhost) <(rabbitmq_permissions $vhost) | awk '{ print $1 }' | tr '\n' ' ')"
    [[ -z $vhost_missing_permissions ]] || missing_permissions+="{ $vhost :: $vhost_missing_permissions } , "
  done
  [[ -z $missing_permissions ]] || $T_fail "There are missing user permissions { vhost :: user } : $missing_permissions"
}
AllSnapshotUserTopicPermissionsStillExist() {
  local missing_topic_permissions
  for vhost in $(store_vhosts)
  do
    local vhost_missing_topic_permissions
    vhost_missing_topic_permissions="$(comm -23 <(store_topic_permissions $vhost) <(rabbitmq_topic_permissions $vhost) | awk '{ print $1"-"$2 }' | tr '\n' ' ')"
    [[ -z $vhost_missing_topic_permissions ]] || missing_topic_permissions+="{ $vhost :: $vhost_missing_topic_permissions } , "
  done
  [[ -z $missing_topic_permissions ]] || $T_fail "There are missing user topic permissions { vhost :: user-topic }  : $missing_topic_permissions"
}
AllSnapshotUserTopicPermissionsStillExist_if_supported() {
  if is_topic_permissions_supported
  then
    AllSnapshotUserTopicPermissionsStillExist
  else
    echo "Skipped Topic Permissions. It is not supported"
  fi
}
T_AllSnapshotUsersStillExist() {
  if store_users_exists; then
    AllSnapshotUserTagsStillExist
    AllSnapshotUserPermissionsStillExist
    AllSnapshotUserTopicPermissionsStillExist_if_supported
  else
    echo "There is no snapshot users in store"
  fi
}

#!/usr/bin/env bash

[[ $DEBUG = true ]] && set -x

TEST="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# basht macro, shellcheck fix
export T_fail

# shellcheck disable=SC1090
source $TEST/test_helpers

T_CanAccessManagementAPI() {
  local actual expected

  expected="200"
  actual=`management_api_status "overview"`

  expect_to_equal "${actual}" "${expected}" || $T_fail
}

T_CanAccessManagementUI() {
  local actual expected

  expected="200"
  actual=`management_ui_status "overview"`

  expect_to_equal "${actual}" "${expected}" || $T_fail
}

T_CanDeclareQueueAndUseItToPublishAndConsume() {
  local actual expected

  expected="ok"
  actual=`management_api "aliveness-test/%2F" | jq -r .status`

  expect_to_equal "${actual}" "${expected}" || $T_fail
}

management_api() {
  local url="https://${RMQ_MANAGEMENT_URI}/api/$1"
  local credentials="-u ${RMQ_SERVER_ADMIN_USER}:${RMQ_SERVER_ADMIN_PASS}"
  local insecure="-k"
  local silent="-s"

  curl $silent $insecure $credentials $url
}

management_api_status() {
  local url="https://${RMQ_MANAGEMENT_URI}/api/$1"
  local credentials="-u ${RMQ_SERVER_ADMIN_USER}:${RMQ_SERVER_ADMIN_PASS}"
  local insecure="-k"
  local silent="-s"
  local printStatusCode="-w %{http_code}"
  local dumpHttpResponse="-o /dev/null"

  curl $printStatusCode $silent $insecure $credentials $url $dumpHttpResponse
}

management_ui_status() {
  local url="${RMQ_MANAGEMENT_URL}"
  local insecure="-k"
  local silent="-s"
  local printStatusCode="-w %{http_code}"
  local dumpHttpResponse="-o /dev/null"

  curl $printStatusCode $silent $insecure $credentials $url $dumpHttpResponse
}

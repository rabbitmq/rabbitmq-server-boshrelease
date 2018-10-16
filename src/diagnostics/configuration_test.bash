#!/usr/bin/env bash

[[ $DEBUG = true ]] && set -x

TEST="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# basht macro, shellcheck fix
export T_fail

# shellcheck disable=SC1090
source $TEST/test_helpers


T_ConfiguredErlangVersionIsRunning() {
  local actual expected

  actual="$(which erl)"
  expected="${ERLANG_VERSION:?must be set}"

  expect_to_contain "${actual}" "erlang-${expected}/bin/erl" || $T_fail "Erlang version '${actual}' does not match expected version '${expected}'"
}

T_ConfiguredRabbitMQVersionIsRunning() {
  local actual expected

  actual="$(rabbitmqctl eval 'rabbit_misc:version().')"
  expected="${RABBITMQ_SERVER_PACKAGE_VERSION:?must be set}"

  expect_to_equal "${actual}" "\"${expected}\"" || $T_fail "RabbitMQ version '${actual}' does not match expected version '${expected}'"
}

#!/usr/bin/env bash

[[ $DEBUG = true ]] && set -x

TEST="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# basht macro, shellcheck fix
export T_fail

# IMPORTs section
# shellcheck disable=SC1090
source $TEST/test_helpers

# shellcheck disable=SC1090
source $TEST/rabbitmq-plugins_helpers

# shellcheck disable=SC1090
source $TEST/rabbitmq-job_helpers


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

allPluginsShouldBeEnabled() {
  expect_to_contain "$(rabbitmq-plugins-installed-list | tr '\n' ',')" "$(rabbitmq-plugins-all-enabled-list | tr '\n' ',')"
}

allConfiguredPluginsShouldBeEnabled() {
  for plugin in $(rabbitmq-job-OnlyEnableThesePlugins); do expect_to_contain "$(rabbitmq-plugins-all-enabled-list)" "$plugin" ; done
}
allExplicitlyEnabledShouldBeConfigured() {
  for plugin in $(rabbitmq-plugins-explicitly-enabled-list); do expect_to_contain "$(rabbitmq-job-OnlyEnableThesePlugins)" "$plugin" ; done
}

T_ConfiguredPluginsAreEnabled() {
  if [ -z "$(rabbitmq-job-OnlyEnableThesePlugins)" ]; then
    allPluginsShouldBeEnabled
  else
    allConfiguredPluginsShouldBeEnabled
    allExplicitlyEnabledShouldBeConfigured
  fi
}

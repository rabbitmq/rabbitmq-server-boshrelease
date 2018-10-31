#!/usr/bin/env bash

[[ $DEBUG = true ]] && set -x

TEST="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# basht macro, shellcheck fix
export T_fail

# IMPORTs section
# shellcheck disable=SC1090
source $TEST/test_helpers

# shellcheck disable=SC1090
source $TEST/rabbitmq_helpers

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
  expect_to_contain "$(rabbitmq_plugins_installed_list | tr '\n' ',')" "$(rabbitmq_plugins_all_enabled_list | tr '\n' ',')"
}

allConfiguredPluginsShouldBeEnabled() {
  local failure_count=0

  for plugin in $(rabbitmq_config_OnlyEnableThesePlugins); do
    expect_to_contain "$(rabbitmq_plugins_all_enabled_list)" "$plugin" || failure_count=$((failure_count+1))
  done
  return $failure_count
}
allExplicitlyEnabledShouldBeConfigured() {
  local failure_count=0

  for plugin in $(rabbitmq_plugins_explicitly_enabled_list); do
    expect_to_contain "$(rabbitmq_config_OnlyEnableThesePlugins)" "$plugin" || failure_count=$((failure_count+1))
  done
  return $failure_count
}

T_ConfiguredPluginsAreEnabled() {
  if [ -z "$(rabbitmq_config_OnlyEnableThesePlugins)" ]; then
    allPluginsShouldBeEnabled
  else
    allConfiguredPluginsShouldBeEnabled
  fi
}
T_ExplicitlyEnabledPluginsShouldBeConfigured() {
  if [ -z "$(rabbitmq_config_OnlyEnableThesePlugins)" ]; then
    allPluginsShouldBeEnabled
  else
    allExplicitlyEnabledShouldBeConfigured
  fi
}

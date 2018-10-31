#!/usr/bin/env bash

[[ $DEBUG = true ]] && set -x

TEST="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# basht macro, shellcheck fix
export T_fail

# IMPORTs section
# shellcheck disable=SC1090
source $TEST/../test_helpers

# shellcheck disable=SC1090
source $TEST/../rabbitmq_helpers

T_RabbitMQIsReadyToServiceAMQP() {
  nc -vz "$(hostname -I)" 5672
}

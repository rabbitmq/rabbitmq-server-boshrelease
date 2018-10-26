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

ConnectToRabbitMQ() {
  cat << EOF
import pika

connection = pika.BlockingConnection(pika.ConnectionParameters(
    host="127.0.0.1", port=5672,
    credentials=pika.PlainCredentials(username="${RABBITMQ_ADMIN_USER}", password="${RABBITMQ_ADMIN_PASS}")))
channel = connection.channel()
print(" Connection establihed ")
connection.close()
EOF
}

T_RabbitMQIsReadyToServiceAMQP() {
  ConnectToRabbitMQ | python3
}

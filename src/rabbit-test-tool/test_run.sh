#!/usr/bin/env bash

set -euxo pipefail

DEPLOYMENT_MANIFEST=../../deployment_configurations/*.yml

export PLAYLIST_LOAD_PATH=../../jobs/rabbitmq-perf-test/templates

python3 run-playlist.py \
    --tags "foo" \
    --playlist-file playlists/qq-point-to-point-safe.json \
    --gap-seconds 10 \
    --config-tag "bosh-foo" \
    --technology rabbitmq \
    --instance "$(bosh int --path /rmq_vm_type ${DEPLOYMENT_MANIFEST})" \
    --volume "$(bosh int --path /rmq_persistent_disk_type ${DEPLOYMENT_MANIFEST})" \
    --filesystem "$(bosh int --path /bosh_stemcell_name ${DEPLOYMENT_MANIFEST})" \
    --tenancy "default" \
    --core-count 0 \
    --threads-per-core 0 \
    --username "broker-username" \
    --password "broker-password" \
    --version "$(bosh int --path /rmq_server_release ${DEPLOYMENT_MANIFEST})" \
    --broker-hosts "10.0.0.1:5672,10.0.0.2:5672,10.0.0.3:5672"
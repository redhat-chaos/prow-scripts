#!/bin/bash

set -ex

ls

# Source env.sh to read all the vars
source env.sh

export KUBECONFIG=$KRKN_KUBE_CONFIG

# cluster version
echo "Printing cluster version"
oc version

source syn-flood/env.sh
krkn_loc=/home/krkn/kraken

# Substitute config with environment vars defined
envsubst < config.yaml.template > /tmp/syn_flood_config.yaml

# Run Kraken
cat /tmp/syn_flood_config.yaml
python3.9 $krkn_loc/run_kraken.py --config=/tmp/syn_flood_config.yaml -o /tmp/report.out 2>&1
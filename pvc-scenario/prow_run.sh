#!/bin/bash

set -ex

ls

# Source env.sh to read all the vars
source env.sh

export KUBECONFIG=$KRKN_KUBE_CONFIG

# cluster version
echo "Printing cluster version"
oc version


source pvc-scenario/env.sh

krkn_loc=/root/kraken

# Substitute config with environment vars defined
envsubst < pvc-scenario/pvc_scenario.yaml.template > /tmp/pvc-scenario/pvc_scenario.yaml
export SCENARIO_FILE="/tmp/pvc-scenario/pvc_scenario.yaml"
envsubst < config.yaml.template > /tmp/pvc_scenario_config.yaml

# Run Kraken
cat /tmp/pvc_scenario_config.yaml
cat /tmp/pvc-scenario/pvc_scenario.yaml
python3.9 $krkn_loc/run_kraken.py --config=/tmp/pvc_scenario_config.yaml 2>&1


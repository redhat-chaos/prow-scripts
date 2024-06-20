#!/bin/bash

set -ex
ls

# Source env.sh to read all the vars
source env.sh

export KUBECONFIG=$KRKN_KUBE_CONFIG

# cluster version
echo "Printing cluster version"
oc version

source container-scenarios/env.sh

krkn_loc=/home/krkn/kraken
# Make krkn executable
sudo chmod -R 755 $krkn_loc

# Substitute config with environment vars defined
envsubst < container-scenarios/container_scenario.yaml.template > /tmp/container_scenario.yaml
export SCENARIO_FILE="- /tmp/container_scenario.yaml"
envsubst < config.yaml.template > /tmp/container_scenario_config.yaml

# Run Kraken
cat /tmp/container_scenario_config.yaml
cat /tmp/container_scenario.yaml
python3.9 $krkn_loc/run_kraken.py --config=/tmp/container_scenario_config.yaml -o /tmp/report.out


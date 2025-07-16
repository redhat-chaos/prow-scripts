#!/bin/bash

set -ex

ls

# Source env.sh to read all the vars
source env.sh
source common_run.sh
source node-scenarios/env.sh
checks

export KUBECONFIG=$KRKN_KUBE_CONFIG

# cluster version
echo "Printing cluster version"
oc version

cp -r /home/krkn/kraken /tmp/kraken
krkn_loc=/tmp/kraken

# Choose the right template based on cloud type
if [ "$CLOUD_TYPE" = "baremetal" ]; then
    TEMPLATE_FILE="node-scenarios/baremetal_node_scenario.yaml.template"
else
    TEMPLATE_FILE="node-scenarios/node_scenario.yaml.template"
fi

# Substitute config with environment vars defined
envsubst < $TEMPLATE_FILE > /tmp/node_scenario.yaml
export SCENARIO_TYPE=node_scenarios


export SCENARIO_FILE=/tmp/node_scenario.yaml
envsubst < config.yaml.template > /tmp/node_scenario_config.yaml

# Run Kraken
cat /tmp/node_scenario.yaml
cat /tmp/node_scenario_config.yaml
python3.9 $krkn_loc/run_kraken.py --config=/tmp/node_scenario_config.yaml -o /tmp/report.out

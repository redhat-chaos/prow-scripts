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
# Make krkn executable
sudo chmod -R 755 $krkn_loc

# Substitute config with environment vars defined
if [[ "$CLOUD_TYPE" == "vmware" || "$CLOUD_TYPE" == "ibmcloud" ]]; then
  envsubst < node-scenarios/plugin_node_scenario.yaml.template > /tmp/node_scenario.yaml
  export SCENARIO_TYPE="plugin_scenarios"
  export ACTION=${ACTION:="$CLOUD_TYPE-node-reboot"}
else
  envsubst < node-scenarios/node_scenario.yaml.template > /tmp/node_scenario.yaml
fi
export SCENARIO_TYPE=node_scenarios
export SCENARIO_FILE=/tmp/node_scenario.yaml
envsubst < config.yaml.template > /tmp/node_scenario_config.yaml

# Run Kraken
cat /tmp/node_scenario.yaml
cat /tmp/node_scenario_config.yaml
python3.9 $krkn_loc/run_kraken.py --config=/tmp/node_scenario_config.yaml -o /tmp/report.out

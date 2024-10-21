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

# Substitute config with environment vars defined
if [[ "$CLOUD_TYPE" == "vmware" ]]; then
  export ACTION=${ACTION:="$CLOUD_TYPE-node-reboot"}
  ## Set to True if you want to verify the vSphere client session using certificates; else False
  export VERIFY_SESSION="verify_session: $VERIFY_SESSION"
  export SKIP_OPENSHIFT_CHECKS="skip_openshift_checks: $SKIP_OPENSHIFT_CHECKS"

  env
  envsubst < node-scenarios/plugin_node_scenario.yaml.template > /tmp/node_scenario.yaml
  export SCENARIO_TYPE="vmware_node_scenarios"
  
elif [[ "$CLOUD_TYPE" == "ibmcloud" ]]; then
  export ACTION=${ACTION:="$CLOUD_TYPE-node-reboot"}
  # IBM doesnt have verify session
  # Invalid parameter 'verify_session', expected one of: name, runs, label_selector, timeout, instance_count, skip_openshift_checks, kubeconfig_path

  export SKIP_OPENSHIFT_CHECKS=""
  export VERIFY_SESSION=""

  env
  envsubst < node-scenarios/plugin_node_scenario.yaml.template > /tmp/node_scenario.yaml
  export SCENARIO_TYPE="ibmcloud_node_scenarios"
  
else
  envsubst < node-scenarios/node_scenario.yaml.template > /tmp/node_scenario.yaml
  export SCENARIO_TYPE=node_scenarios

fi

export SCENARIO_FILE=/tmp/node_scenario.yaml
envsubst < config.yaml.template > /tmp/node_scenario_config.yaml

# Run Kraken
cat /tmp/node_scenario.yaml
cat /tmp/node_scenario_config.yaml
python3.9 $krkn_loc/run_kraken.py --config=/tmp/node_scenario_config.yaml -o /tmp/report.out

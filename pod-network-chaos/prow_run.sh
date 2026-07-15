#!/bin/bash

set -ex

ls

# Source env.sh to read all the vars
source env.sh

export KUBECONFIG=$KRKN_KUBE_CONFIG


# Cluster details
echo "Printing cluster details"
oc version 

source pod-network-chaos/env.sh

krn_loc=/home/krkn/kraken

# Substitute config with environment vars defined
if [[ -z $NAMESPACE ]]; then
  echo "Requires NAMASPACE parameter to be set, please check"
  exit 1
fi
envsubst < pod-network-chaos/pod_network_scenario.yaml.template > /tmp/pod_network_scenario.yaml
export SCENARIO_FILE="/tmp/pod_network_scenario.yaml"
envsubst < config.yaml.template > /tmp/pod_network_scenario_config.yaml

cat /tmp/pod_network_scenario_config.yaml
cat /tmp/pod_network_scenario.yaml

[ -z "$JUNIT_TESTCASE" ] && JUNIT_TESTCASE="pod-network-chaos"
[ -z "$ARTIFACT_DIR" ] && ARTIFACT_DIR="/tmp"
TEST_VERSION=$(oc version -o json | jq -r '.openshiftVersion')

python3.11 $krn_loc/run_kraken.py --config=/tmp/pod_network_scenario_config.yaml \
-o /tmp/report.out \
--junit-testcase "$JUNIT_TESTCASE" \
--junit-testcase-path "$ARTIFACT_DIR" \
--junit-testcase-version "$TEST_VERSION"

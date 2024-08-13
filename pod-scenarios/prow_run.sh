#!/bin/bash

set -ex

ls

# Source env.sh to read all the vars
source env.sh

export KUBECONFIG=$KRKN_KUBE_CONFIG


# cluster version
echo "Printing cluster version"
oc version

source pod-scenarios/env.sh

krn_loc=/home/krkn/kraken

# Substitute config with environment vars defined
if [[ -z "$POD_LABEL" ]]; then
  envsubst < pod-scenarios/pod_scenario_namespace.yaml.template > /tmp/pod_scenario.yaml
else  
  envsubst < pod-scenarios/pod_scenario.yaml.template > /tmp/pod_scenario.yaml
fi
export SCENARIO_FILE=/tmp/pod_scenario.yaml
envsubst < config.yaml.template > /tmp/pod_scenario_config.yaml

cat /tmp/pod_scenario_config.yaml
cat /tmp/pod_scenario.yaml

[ -z $JUNIT_TESTCASE ] && JUNIT_TESTCASE="Pod scenarios"
[ -z $ARTIFACT_DIR ] && ARTIFACT_DIR="/tmp"

TEST_VERSION=`oc version -o json | jq .openshiftVersion`

python3.9 $krn_loc/run_kraken.py --config=/tmp/pod_scenario_config.yaml \
-o /tmp/report.out \
--junit-testcase "$JUNIT_TESTCASE" \
--junit-testcase-path "$ARTIFACT_DIR" \
--junit-testcase-version "$TEST_VERSION"
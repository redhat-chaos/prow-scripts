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

krkn_loc=/home/krkn/kraken

# Substitute config with environment vars defined
envsubst < pvc-scenario/pvc_scenario.yaml.template > /tmp/pvc_scenario.yaml
export SCENARIO_FILE="/tmp/pvc_scenario.yaml"
envsubst < config.yaml.template > /tmp/pvc_scenario_config.yaml

# Run Kraken
cat /tmp/pvc_scenario_config.yaml
cat /tmp/pvc_scenario.yaml

[ -z "$JUNIT_TESTCASE" ] && JUNIT_TESTCASE="pvc-scenario"
[ -z "$ARTIFACT_DIR" ] && ARTIFACT_DIR="/tmp"
TEST_VERSION=$(oc version -o json | jq -r '.openshiftVersion')

python3.11 $krkn_loc/run_kraken.py --config=/tmp/pvc_scenario_config.yaml \
-o /tmp/report.out \
--junit-testcase "$JUNIT_TESTCASE" \
--junit-testcase-path "$ARTIFACT_DIR" \
--junit-testcase-version "$TEST_VERSION" 2>&1


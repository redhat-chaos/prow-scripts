#!/bin/bash

set -ex

ls

# Source env.sh to read all the vars
source env.sh
source common_run.sh
source power-outages/env.sh
checks

export KUBECONFIG=$KRKN_KUBE_CONFIG

# cluster version
echo "Printing cluster version"
oc version

# Substitute config with environment vars defined
envsubst < power-outages/shutdown_scenario.yaml.template > /tmp/power_outage_scenario.yaml
export SCENARIO_FILE="/tmp/power_outage_scenario.yaml"
envsubst < config.yaml.template > /tmp/power_outage_config.yaml

# Run Kraken
cat /tmp/power_outage_scenario.yaml
cat /tmp/power_outage_config.yaml

[ -z "$JUNIT_TESTCASE" ] && JUNIT_TESTCASE="power-outage"
[ -z "$ARTIFACT_DIR" ] && ARTIFACT_DIR="/tmp"
TEST_VERSION=$(oc version -o json | jq -r '.openshiftVersion')

python3.11 /home/krkn/kraken/run_kraken.py --config=/tmp/power_outage_config.yaml \
-o /tmp/report.out \
--junit-testcase "$JUNIT_TESTCASE" \
--junit-testcase-path "$ARTIFACT_DIR" \
--junit-testcase-version "$TEST_VERSION"

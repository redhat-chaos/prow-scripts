#!/bin/bash

set -ex
ls

# Source env.sh to read all the vars
source env.sh

export KUBECONFIG=$KRKN_KUBE_CONFIG

# cluster version
echo "Printing cluster version"
oc version

source application-outages/env.sh

krkn_loc=/home/krkn/kraken

# Substitute config with environment vars defined
envsubst < application-outages/app_outages.yaml.template > /tmp/app_outages.yaml
export SCENARIO_FILE="/tmp/app_outages.yaml"
envsubst < config.yaml.template > /tmp/app_outages_config.yaml

# Run Kraken
cat /tmp/app_outages_config.yaml
cat /tmp/app_outages.yaml

[ -z "$JUNIT_TESTCASE" ] && JUNIT_TESTCASE="application-outages"
[ -z "$ARTIFACT_DIR" ] && ARTIFACT_DIR="/tmp"
TEST_VERSION=$(oc version -o json | jq -r '.openshiftVersion')

python3.11 $krkn_loc/run_kraken.py --config=/tmp/app_outages_config.yaml \
-o /tmp/report.out \
--junit-testcase "$JUNIT_TESTCASE" \
--junit-testcase-path "$ARTIFACT_DIR" \
--junit-testcase-version "$TEST_VERSION"


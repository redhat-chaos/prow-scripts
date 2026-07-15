#!/bin/bash

set -ex

ls

# Source env.sh to read all the vars
source env.sh

export KUBECONFIG=$KRKN_KUBE_CONFIG

# cluster version
echo "Printing cluster version"
oc version

source syn-flood/env.sh
krkn_loc=/home/krkn/kraken

# Substitute config with environment vars defined
envsubst < syn-flood/syn-flood.yaml.template > /tmp/syn_flood.yaml
export SCENARIO_FILE="/tmp/syn_flood.yaml"
envsubst < config.yaml.template > /tmp/syn_flood_config.yaml


# Run Kraken
cat /tmp/syn_flood_config.yaml

[ -z "$JUNIT_TESTCASE" ] && JUNIT_TESTCASE="syn-flood"
[ -z "$ARTIFACT_DIR" ] && ARTIFACT_DIR="/tmp"
TEST_VERSION=$(oc version -o json | jq -r '.openshiftVersion')

python3.11 $krkn_loc/run_kraken.py --config=/tmp/syn_flood_config.yaml \
-o /tmp/report.out \
--junit-testcase "$JUNIT_TESTCASE" \
--junit-testcase-path "$ARTIFACT_DIR" \
--junit-testcase-version "$TEST_VERSION" 2>&1
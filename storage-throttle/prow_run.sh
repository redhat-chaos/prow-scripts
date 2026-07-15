#!/bin/bash

set -ex

ls

# Source env.sh to read all the vars
source env.sh

export KUBECONFIG=$KRKN_KUBE_CONFIG

# cluster version
echo "Printing cluster version"
oc version

source storage-throttle/env.sh
source common_run.sh

krkn_loc=/home/krkn/kraken

# Substitute config with environment vars defined
envsubst < storage-throttle/storage_throttle.yaml.template > /tmp/storage_throttle.yaml
export SCENARIO_FILE="/tmp/storage_throttle.yaml"
envsubst < config.yaml.template > /tmp/storage_throttle_config.yaml

checks

# Run Kraken
cat /tmp/storage_throttle_config.yaml
cat /tmp/storage_throttle.yaml

[ -z "$JUNIT_TESTCASE" ] && JUNIT_TESTCASE="storage-throttle"
[ -z "$ARTIFACT_DIR" ] && ARTIFACT_DIR="/tmp"
TEST_VERSION=$(oc version -o json | jq -r '.openshiftVersion')

python3.11 $krkn_loc/run_kraken.py --config=/tmp/storage_throttle_config.yaml \
-o /tmp/report.out \
--junit-testcase "$JUNIT_TESTCASE" \
--junit-testcase-path "$ARTIFACT_DIR" \
--junit-testcase-version "$TEST_VERSION"

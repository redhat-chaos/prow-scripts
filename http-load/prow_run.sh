#!/bin/bash

set -ex

ls

# Source env.sh to read all the vars
source env.sh

export KUBECONFIG=$KRKN_KUBE_CONFIG

# cluster version
echo "Printing cluster version"
oc version

source http-load/env.sh
source common_run.sh

krkn_loc=/home/krkn/kraken

# Build scenario config from environment variables
python3.11 /home/krkn/build_config_file.py --outconfig $krkn_loc/scenarios/http-load.yaml

# Substitute config with environment vars defined
export SCENARIO_FILE="$krkn_loc/scenarios/http-load.yaml"
envsubst < config.yaml.template > /tmp/http_load_config.yaml

checks

# Run Kraken
cat /tmp/http_load_config.yaml
cat $krkn_loc/scenarios/http-load.yaml

[ -z "$JUNIT_TESTCASE" ] && JUNIT_TESTCASE="http-load"
[ -z "$ARTIFACT_DIR" ] && ARTIFACT_DIR="/tmp"
TEST_VERSION=$(oc version -o json | jq -r '.openshiftVersion')

cd $krkn_loc
python3.11 run_kraken.py --config=/tmp/http_load_config.yaml \
-o /tmp/report.out \
--junit-testcase "$JUNIT_TESTCASE" \
--junit-testcase-path "$ARTIFACT_DIR" \
--junit-testcase-version "$TEST_VERSION"

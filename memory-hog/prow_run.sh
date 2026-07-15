#!/bin/bash

set -ex

ls

# Source env.sh to read all the vars
source env.sh

export KUBECONFIG=$KRKN_KUBE_CONFIG
krkn_loc=/home/krkn/kraken
sub_scenario_folder="scenarios/kube/"
SCENARIO_FOLDER="$krkn_loc/$sub_scenario_folder"

# cluster version
echo "Printing cluster version"
oc version

source node-memory-hog/env.sh
source common_run.sh

envsubst < node-memory-hog/memory-hog.yml.template > $krkn_loc/scenarios/kube/memory-hog.yml

# Substitute config with environment vars defined
export SCENARIO_FILE="$sub_scenario_folder/memory-hog.yml"

# Substitute config with environment vars defined
envsubst < config.yaml.template > $krkn_loc/config/memory_hog_config.yaml

checks

# Run Kraken
cd $krkn_loc
cat config/memory_hog_config.yaml
cat $SCENARIO_FILE

[ -z "$JUNIT_TESTCASE" ] && JUNIT_TESTCASE="memory-hog"
[ -z "$ARTIFACT_DIR" ] && ARTIFACT_DIR="/tmp"
TEST_VERSION=$(oc version -o json | jq -r '.openshiftVersion')

python3.11 run_kraken.py --config=config/memory_hog_config.yaml \
-o /tmp/report.out \
--junit-testcase "$JUNIT_TESTCASE" \
--junit-testcase-path "$ARTIFACT_DIR" \
--junit-testcase-version "$TEST_VERSION"


#!/bin/bash

set -ex

ls

# Source env.sh to read all the vars
source env.sh

export KUBECONFIG=$KRKN_KUBE_CONFIG
krkn_loc=/home/krkn/kraken
sub_scenario_folder="scenarios/kube"
SCENARIO_FOLDER="$krkn_loc/$sub_scenario_folder"

# cluster version
echo "Printing cluster version"
oc version

source node-cpu-hog/env.sh
source common_run.sh

checks

# Substitute config with environment vars defined
envsubst < node-cpu-hog/cpu-hog.yml.template > $krkn_loc/scenarios/kube/cpu-hog.yml
export SCENARIO_FILE="$sub_scenario_folder/cpu-hog.yml"
envsubst < config.yaml.template > $krkn_loc/cpu_hog_config.yaml


# Run Kraken
cd $krkn_loc
cat cpu_hog_config.yaml
cat $SCENARIO_FILE

[ -z "$JUNIT_TESTCASE" ] && JUNIT_TESTCASE="cpu-hog"
[ -z "$ARTIFACT_DIR" ] && ARTIFACT_DIR="/tmp"
TEST_VERSION=$(oc version -o json | jq -r '.openshiftVersion')

python3.11 run_kraken.py --config=cpu_hog_config.yaml \
-o /tmp/report.out \
--junit-testcase "$JUNIT_TESTCASE" \
--junit-testcase-path "$ARTIFACT_DIR" \
--junit-testcase-version "$TEST_VERSION"

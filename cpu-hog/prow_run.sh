#!/bin/bash

set -ex

ls

# Source env.sh to read all the vars
source env.sh

export KUBECONFIG=$KRKN_KUBE_CONFIG
krkn_loc=/home/krkn/kraken
SCENARIO_FOLDER="$krkn_loc/scenarios/arcaflow/cpu-hog"

# cluster version
echo "Printing cluster version"
oc version

# Copy config to kraken
cp node-cpu-hog/input.yaml.template $SCENARIO_FOLDER/input.yaml.template

source node-cpu-hog/env.sh
source env.sh
source common_run.sh

setup_arcaflow_env "$SCENARIO_FOLDER"
checks

# Substitute config with environment vars defined
#envsubst < node-cpu-hog/input.yaml.template> node-cpu-hog/cpu_hog_scenario.yaml
#export SCENARIO_FILE="node-cpu-hog/cpu_hog_scenario.yaml"
export SCENARIO_FILE="$SCENARIO_FOLDER/input.yaml"
envsubst < config.yaml.template > $krkn_loc/cpu_hog_config.yaml

# Run Kraken
cat $krkn_loc/cpu_hog_config.yaml
cat $SCENARIO_FOLDER/input.yaml
python3.9 $krkn_loc/run_kraken.py --config=$krkn_loc/cpu_hog_config.yaml -o /tmp/report.out

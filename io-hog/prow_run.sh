#!/bin/bash

set -ex

ls

# Source env.sh to read all the vars
source env.sh

export KUBECONFIG=$KRKN_KUBE_CONFIG
krkn_loc=/home/krkn/kraken
SCENARIO_FOLDER="$krkn_loc/scenarios/kube/io-hog"

# cluster version
echo "Printing cluster version"
oc version

source node-io-hog/env.sh
source common_run.sh

cp node-io-hog/input.yaml.template $SCENARIO_FOLDER/input.yaml.template
setup_arcaflow_env "$SCENARIO_FOLDER"
checks

# Substitute config with environment vars defined
export SCENARIO_FILE="scenarios/arcaflow/io-hog/input.yaml"
envsubst < config.yaml.template > $krkn_loc/io_hog_config.yaml

# Run Kraken
cat $krkn_loc/io_hog_config.yaml
cat $SCENARIO_FOLDER/input.yaml
cd $krkn_loc
python3.9 run_kraken.py --config=io_hog_config.yaml -o /tmp/report.out


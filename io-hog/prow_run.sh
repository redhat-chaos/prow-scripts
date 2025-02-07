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

source node-io-hog/env.sh
source common_run.sh

envsubst < $krkn_loc/scenarios/kube/io-hog.yml.template > $krkn_loc/scenarios/kube/io-hog.yml

# Substitute config with environment vars defined
export SCENARIO_FILE="$sub_scenario_folder/io-hog.yml"

# Substitute config with environment vars defined
envsubst < config.yaml.template > $krkn_loc/io_hog_config.yaml

checks
config_setup
# Run Kraken

cd $krkn_loc
cat io_hog_config.yaml
cat $SCENARIO_FILE

python3.9 run_kraken.py --config=io_hog_config.yaml -o /tmp/report.out


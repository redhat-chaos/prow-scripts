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
# Make krkn executable
sudo chmod -R 755 $krkn_loc

# Substitute config with environment vars defined
envsubst < application-outages/app_outages.yaml.template > /tmp/app_outages.yaml
export SCENARIO_FILE="/tmp/app_outages.yaml"
envsubst < config.yaml.template > /tmp/app_outages_config.yaml

# Run Kraken
cat /tmp/app_outages_config.yaml
cat /tmp/app_outages.yaml
python3.9 $krkn_loc/run_kraken.py --config=/tmp/app_outages_config.yaml -o /tmp/report.out


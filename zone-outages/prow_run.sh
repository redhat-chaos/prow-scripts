#!/bin/bash

set -ex

ls

# Source env.sh to read all the vars
source env.sh
source common_run.sh
source zone-outages/env.sh
checks

export KUBECONFIG=$KRKN_KUBE_CONFIG

krn_loc=/home/krkn/kraken

# cluster version
echo "Printing cluster version"
oc version



# Substitute config with environment vars defined


if [[ "$CLOUD_TYPE" == "gcp" ]]; then
    envsubst < zone-outages/zone_outage_scenario_gcp.yaml.template >  /tmp/zone_outage.yaml
else 
    envsubst < zone-outages/zone_outage_scenario.yaml.template > /tmp/zone_outage.yaml
fi 

export SCENARIO_FILE=/tmp/zone_outage.yaml

envsubst < config.yaml.template > /tmp/zone_config.yaml

# Run Kraken
cat /tmp/zone_outage.yaml
cat /tmp/zone_config.yaml
python3.9 $krn_loc/run_kraken.py --config=/tmp/zone_config.yaml -o /tmp/report.out

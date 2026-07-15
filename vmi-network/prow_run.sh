#!/bin/bash

set -ex

ls

# Source env.sh to read all the vars
source env.sh

export KUBECONFIG=$KRKN_KUBE_CONFIG

# cluster version
echo "Printing cluster version"
oc version

source vmi-network/env.sh
source common_run.sh

krkn_loc=/home/krkn/kraken
SCENARIO_FOLDER="$krkn_loc/scenarios/kube"

yq -i ".[0].test_duration=$TEST_DURATION" $SCENARIO_FOLDER/vmi-network-chaos.yml
yq -i ".[0].label_selector=\"$LABEL_SELECTOR\"" $SCENARIO_FOLDER/vmi-network-chaos.yml
yq -i ".[0].namespace=\"$NAMESPACE\"" $SCENARIO_FOLDER/vmi-network-chaos.yml
yq -i ".[0].instance_count=$INSTANCE_COUNT" $SCENARIO_FOLDER/vmi-network-chaos.yml
yq -i ".[0].execution=\"$EXECUTION\"" $SCENARIO_FOLDER/vmi-network-chaos.yml
yq -i ".[0].ingress=$INGRESS" $SCENARIO_FOLDER/vmi-network-chaos.yml
yq -i ".[0].egress=$EGRESS" $SCENARIO_FOLDER/vmi-network-chaos.yml
yq -i ".[0].image=\"$IMAGE\"" $SCENARIO_FOLDER/vmi-network-chaos.yml
yq -i ".[0].target=\"$VMI_NAME\"" $SCENARIO_FOLDER/vmi-network-chaos.yml
yq -i ".[0].service_account=\"$SERVICE_ACCOUNT\"" $SCENARIO_FOLDER/vmi-network-chaos.yml

if [[ -n "$LATENCY" ]]; then
  yq -i ".[0].latency=\"$LATENCY\"" $SCENARIO_FOLDER/vmi-network-chaos.yml
fi

if [[ -n "$LOSS" ]]; then
  yq -i ".[0].loss=\"$LOSS\"" $SCENARIO_FOLDER/vmi-network-chaos.yml
fi

if [[ -n "$BANDWIDTH" ]]; then
  yq -i ".[0].bandwidth=\"$BANDWIDTH\"" $SCENARIO_FOLDER/vmi-network-chaos.yml
fi

IFS=',' read -ra array <<< "$INTERFACES"
for ((i=0; i<${#array[@]}; i++)); do
  yq -i ".[0].interfaces[$i]=\"${array[$i]}\"" $SCENARIO_FOLDER/vmi-network-chaos.yml
done

IFS=',' read -ra array <<< "$TAINTS"
for ((i=0; i<${#array[@]}; i++)); do
  yq -i ".[0].taints[$i]=\"${array[$i]}\"" $SCENARIO_FOLDER/vmi-network-chaos.yml
done

envsubst < config.yaml.template > /tmp/vmi-network-chaos-config.yaml

checks

# Run Kraken
cat $SCENARIO_FOLDER/vmi-network-chaos.yml
cat /tmp/vmi-network-chaos-config.yaml

[ -z "$JUNIT_TESTCASE" ] && JUNIT_TESTCASE="vmi-network"
[ -z "$ARTIFACT_DIR" ] && ARTIFACT_DIR="/tmp"
TEST_VERSION=$(oc version -o json | jq -r '.openshiftVersion')

python3.11 $krkn_loc/run_kraken.py --config=/tmp/vmi-network-chaos-config.yaml \
-o /tmp/report.out \
--junit-testcase "$JUNIT_TESTCASE" \
--junit-testcase-path "$ARTIFACT_DIR" \
--junit-testcase-version "$TEST_VERSION"

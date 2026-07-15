#!/bin/bash

set -ex

ls

# Source env.sh to read all the vars
source env.sh

export KUBECONFIG=$KRKN_KUBE_CONFIG

# cluster version
echo "Printing cluster version"
oc version

source node-interface-down/env.sh
source common_run.sh

krkn_loc=/home/krkn/kraken
SCENARIO_FOLDER="$krkn_loc/scenarios/kube"

yq -i ".[0].test_duration=$TEST_DURATION" $SCENARIO_FOLDER/node-interface-down.yml
yq -i ".[0].label_selector=\"$LABEL_SELECTOR\"" $SCENARIO_FOLDER/node-interface-down.yml
yq -i ".[0].namespace=\"$NAMESPACE\"" $SCENARIO_FOLDER/node-interface-down.yml
yq -i ".[0].instance_count=$INSTANCE_COUNT" $SCENARIO_FOLDER/node-interface-down.yml
yq -i ".[0].execution=\"$EXECUTION\"" $SCENARIO_FOLDER/node-interface-down.yml
yq -i ".[0].image=\"$IMAGE\"" $SCENARIO_FOLDER/node-interface-down.yml
yq -i ".[0].target=\"$NODE_NAME\"" $SCENARIO_FOLDER/node-interface-down.yml
yq -i ".[0].service_account=\"$SERVICE_ACCOUNT\"" $SCENARIO_FOLDER/node-interface-down.yml
yq -i ".[0].recovery_time=$RECOVERY_TIME" $SCENARIO_FOLDER/node-interface-down.yml
yq -i ".[0].wait_duration=$WAIT_DURATION" $SCENARIO_FOLDER/node-interface-down.yml

if [[ -n "$INTERFACES" ]]; then
  IFS=',' read -ra array <<< "$INTERFACES"
  for ((i=0; i<${#array[@]}; i++)); do
    yq -i ".[0].interfaces[$i]=\"${array[$i]}\"" $SCENARIO_FOLDER/node-interface-down.yml
  done
fi

if [[ -n "$TAINTS" ]]; then
  IFS=',' read -ra array <<< "$TAINTS"
  for ((i=0; i<${#array[@]}; i++)); do
    yq -i ".[0].taints[$i]=\"${array[$i]}\"" $SCENARIO_FOLDER/node-interface-down.yml
  done
fi

envsubst < config.yaml.template > /tmp/node-interface-down-config.yaml

checks

# Run Kraken
cat $SCENARIO_FOLDER/node-interface-down.yml
cat /tmp/node-interface-down-config.yaml

[ -z "$JUNIT_TESTCASE" ] && JUNIT_TESTCASE="node-interface-down"
[ -z "$ARTIFACT_DIR" ] && ARTIFACT_DIR="/tmp"
TEST_VERSION=$(oc version -o json | jq -r '.openshiftVersion')

python3.11 $krkn_loc/run_kraken.py --config=/tmp/node-interface-down-config.yaml \
-o /tmp/report.out \
--junit-testcase "$JUNIT_TESTCASE" \
--junit-testcase-path "$ARTIFACT_DIR" \
--junit-testcase-version "$TEST_VERSION"

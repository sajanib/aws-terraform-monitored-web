#!/usr/bin/env bash
# Incident drill: pushes CPU to 100% for 15 minutes so the cpu-high alarm fires,
# then recovers on its own. Run from the repo root after `terraform apply`.
# Requires: AWS CLI v2, credentials for the same account, and a confirmed SNS email.
set -euo pipefail

INSTANCE_ID=$(terraform output -raw instance_id)
REGION=$(terraform output -raw aws_region)
DURATION_SECONDS=${DURATION_SECONDS:-900}

echo "Starting CPU load on $INSTANCE_ID ($REGION) for $DURATION_SECONDS seconds..."

# One busy loop per vCPU, each stopped by `timeout` after DURATION_SECONDS
LOAD_CMD="for i in \$(seq \$(nproc)); do timeout ${DURATION_SECONDS} sh -c 'while :; do :; done' & done; wait"
PARAMS=$(printf '{"commands":["%s"]}' "$LOAD_CMD")

COMMAND_ID=$(aws ssm send-command \
  --region "$REGION" \
  --instance-ids "$INSTANCE_ID" \
  --document-name "AWS-RunShellScript" \
  --comment "incident drill: cpu load" \
  --parameters "$PARAMS" \
  --query "Command.CommandId" --output text)

echo "SSM command sent: $COMMAND_ID"
echo "Watch the alarm:   aws cloudwatch describe-alarms --region $REGION --alarm-name-prefix monitored-web --query 'MetricAlarms[].[AlarmName,StateValue]' --output table"
echo "Expect an ALARM email within ~10-15 minutes, then an OK email after the load stops."
echo "Afterwards, write up what happened in docs/postmortem-cpu-drill.md (template: docs/postmortem-template.md)."

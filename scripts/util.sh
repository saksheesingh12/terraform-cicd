#!/bin/bash
# Author: lars.butler@rackspace.com
# Modified by: nick.garratt@rackspace.co.uk

set -euxo pipefail

function get_aws_account_id {
  local result=$(aws sts get-caller-identity --query 'Account' | sed -e 's/"//g')
  echo "${result}"
}

function get_state_bucket {
  local aws_account_id=${1}
  local VAR="TF_STATE_BUCKET_${aws_account_id}"
  local tf_state_bucket="${!VAR:-$TF_STATE_BUCKET_V2}"
  echo "${tf_state_bucket}"
}

function tf_init {
  local tf_state_bucket="${1}"
  local aws_account_id="${3:-"unset"}"
  local lock="${3:+"true"}"; lock="${lock:-"false"}"
  local queried_region=$(aws s3api get-bucket-location --bucket ${tf_state_bucket} | jq -r '.LocationConstraint')
  # account for AWS inconsistency where `get-bucket-location` returns 'null' for us-east-1
  local queried_region=$(if [ $queried_region == "null" ]; then echo "us-east-1"; else echo $queried_region; fi)
  local tf_state_region=${queried_region:-$tf_state_region_param}
  local cwd="${4}"

  terraform init \
    -no-color \
    -input=false \
    -backend=true \
    -backend-config="bucket=${tf_state_bucket}" \
    -backend-config="region=${tf_state_region}" \
    -backend-config="key=terraform.${cwd}.tfstate" \
    -backend-config="encrypt=true" \
    -backend-config="dynamodb_table=terraform_lock_${aws_account_id}" \
    -lock="${lock}"
}
#!/bin/bash
# Author: lars.butler@rackspace.com
# Modified by: nick.garratt@rackspace.co.uk

set -euxo pipefail

environment="${ENVIRONMENT_NAME}"

# Directory of this script:
SCRIPTS_DIR="$( cd "$(dirname "${0}")" ; pwd -P )"

#source ${SCRIPTS_DIR}/vars.sh
source ${SCRIPTS_DIR}/util.sh

# we may be sharing this container with other builds
PLAN_DIR="${PLANS_DIR}/${environment}"
mkdir -p "${PLAN_DIR}"

function plan_layers {
  local environment="${1}"
  local layers=$(ls ${LAYERS_DIR})
  local aws_account_id=$(get_aws_account_id)
  local state_bucket=$(get_state_bucket $aws_account_id)

  echo "DIAG: AWS_ACCOUNT_ID=${aws_account_id}"
  echo "DIAG: ENVIRONMENT=${environment}"

  for layer in $layers; do
    local layer_dir="${LAYERS_DIR}/${layer}"
    pushd ${layer_dir}

    tf_init ${state_bucket} ${TF_STATE_REGION} ${aws_account_id} ${layer}

    # create and/or switch to the appropriate terraform workspace
    terraform workspace select ${environment} || terraform workspace new ${environment}

    # NOTE: Assume that the .tfvars file exists for this environment:

    terraform plan \
      -no-color \
      -input=false \
      -var-file="envs/${environment}.tfvars" \
      -var "aws_account_id=${aws_account_id}" \
      -var "layer=${layer}" \
      -out="${PLAN_DIR}/${environment}_${layer}.plan"
    popd
  done
}

plan_layers ${environment}

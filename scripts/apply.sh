#!/bin/bash

set -euxo pipefail

environment="${ENVIRONMENT_NAME}"

# Directory of this script:
SCRIPTS_DIR="$( cd "$(dirname "${0}")" ; pwd -P )"


PLAN_DIR="${PLANS_DIR}/${environment}"

function apply_layers {
  local environment="${1}"
  local layers=$(ls ${LAYERS_DIR})
  #local account_details=$(yq -r '.environments.'"$environment" environments.yml)
  local aws_account_id=$(yq -r '.environments[] | select(.name == "'"$environment"'") | .account' environments.yml)
  echo $aws_account_id
  local state_bucket=$(yq -r '.environments[] | select(.name == "'"$environment"'") | .bucket' environments.yml)

  echo "DIAG: AWS_ACCOUNT_ID=${aws_account_id}"
  echo "DIAG: ENVIRONMENT=${environment}"

  for layer in $layers; do
    local layer_dir="${LAYERS_DIR}/${layer}"
    pushd ${layer_dir}
    
    echo "*********************************** Running terraform init on ${layer}***********************************"
    terraform init \
    -no-color \
    -input=false \
    -backend=true \
    -backend-config="bucket=${state_bucket}" \
    -backend-config="region=ap-south-1" \
    -backend-config="key=terraform.${layer}.tfstate " \

    # create and/or switch to the appropriate terraform workspace
    terraform workspace select ${environment} || terraform workspace new ${environment}
    
    echo "*********************************** Running terraform plan on ${layer}***********************************"
    terraform plan \
      -no-color \
      -input=false \
      -var-file="envs/${environment}.tfvars" \
      -var "aws_account_id=${aws_account_id}" \
      -var "layer=${layer}" \
      -out="${PLAN_DIR}/${environment}_${layer}.plan"

    
    echo "*********************************** Running terraform apply on ${layer}***********************************"
    terraform apply \
      -no-color \
      -input=false \
      -auto-approve \
      "${PLAN_DIR}/${environment}_${layer}.plan"
      # we can't use these if we are applying from a previous plan:
      #-var-file="envs/${environment}.tfvars" \
      #-var "aws_account_id=${aws_account_id}" \
    popd
  done
}

apply_layers ${environment}
#!/bin/bash

# Set default output directory for plans (modify if needed)
PLAN_DIR=${PLAN_DIR:-"./plans"}

# Get environment and layer name from folder structure
environment="${ENVIRONMENT_NAME}"
layer="${PWD##*/}"

# Read AWS account ID from environment variable
aws_account_id="${aws_account_id}"

# Run Terraform plan with desired options
terraform plan \
  -no-color \
  -input=false \
  -var-file="envs/${environment}.tfvars" \
  -var "aws_account_id=${aws_account_id}" \
  -var "layer=${layer}" \
  -out="${PLAN_DIR}/${environment}_${layer}.plan"

# Handle potential errors
if [ $? -ne 0 ]; then
  echo "Terraform plan failed for ${environment}/${layer}"
  exit 1
fi

echo "Terraform plan successful for ${environment}/${layer}. Plan file: ${PLAN_DIR}/${environment}_${layer}.plan"

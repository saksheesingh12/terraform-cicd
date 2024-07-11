#!/bin/bash
set -eu

# Directory of this script:
SCRIPTS_DIR="$( cd "$(dirname "${0}")" ; pwd -P )"
REPO_ROOT="${SCRIPTS_DIR}/.."
LAYERS_DIR="${REPO_ROOT}/layers"

environment="${ENVIRONMENT_NAME}"

#source ${SCRIPTS_DIR}/vars.sh
layers=$(ls ${LAYERS_DIR})
state_bucket=$(yq -r '.environments[] | select(.name == "'"$environment"'") | .bucket' environments.yml)

for layer in $layers
do
  pushd ${LAYERS_DIR}/${layer}
  echo "running on layer ${layer}."
      terraform init \
    -no-color \
    -input=false \
    -backend=true \
    -backend-config="bucket=${state_bucket}" \
    -backend-config="region=ap-south-1" \
    -backend-config="key=terraform.${layer}.tfstate " \
  terraform validate
  popd
done
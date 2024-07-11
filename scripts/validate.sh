#!/bin/bash
set -eu

# Directory of this script:
SCRIPTS_DIR="$( cd "$(dirname "${0}")" ; pwd -P )"
REPO_ROOT="${SCRIPTS_DIR}/.."
LAYERS_DIR="${REPO_ROOT}/layers"

environment="${ENVIRONMENT_NAME}"

#source ${SCRIPTS_DIR}/vars.sh
layers=$(ls ${LAYERS_DIR})

for layer in $layers
do
  pushd ${LAYERS_DIR}/${layer}
  echo "running on layer ${layer}."
  terraform validate
  popd
done
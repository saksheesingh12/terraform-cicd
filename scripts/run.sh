#!/bin/bash
set -euxo pipefail

SCRIPTS_DIR="$( cd "$(dirname "${0}")" ; pwd -P )"

source ${SCRIPTS_DIR}/vars.sh

environment="${1}"
environment_config="${SCRIPTS_DIR}/../environments.yml"
cmd="${@:2}"

# prepare environment for AWS access using RS_USERNAME and RS_API_KEY to vend credentials
# see: https://github.com/rackerlabs/fleece
function fleece_run {
  local environment="${2}"
  local environment_config="${1}"
  # Remaining args are the `fleece run` command
  local cmd="${@:3}"
  fleece run \
    --config ${environment_config} \
    --environment ${environment} \
    -- ${cmd}
  echo ${cmd}
}

fleece_run ${environment_config} ${environment} ${cmd}

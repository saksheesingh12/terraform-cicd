#!/bin/bash
# Author: lars.butler@rackspace.com
# Modified by: nick.garratt@rackspace.co.uk

#set -euo pipefail
## Disable verbose mode when checking for credentials.
#set +x
## Get/check if username and API are present before running this script.
## This is needed for `fleece run` (see https://github.com/rackerlabs/fleece)
#RS_USERNAME=${RS_USERNAME:?"Rackspace username not set"}
#RS_API_KEY=${RS_API_KEY:?"Rackspace API key not set"}
#
## CircleCI environment variables
## These values are only relevant for the Phoenix linked account
## Account specific state buckets are configured in the CircleCI environment as TF_STATE_BUCKET_${aws_account_number}
## see get_state_bucket() in util.sh
#TF_STATE_BUCKET="${TF_STATE_BUCKET:-$TF_STATE_BUCKET_V2}"
#TF_STATE_REGION="${TF_STATE_REGION:-$TF_STATE_REGION_V2}"

# Set verbose mode, but not before setting the credentials
# (we don't want these leaking into logs, etc.)
set -x

REPO_ROOT="${SCRIPTS_DIR}/.."
LAYERS_DIR="${REPO_ROOT}/layers"
PLANS_DIR="${REPO_ROOT}/plans"

# This directory should always exist
mkdir -p "${PLANS_DIR}"
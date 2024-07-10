#!/bin/bash
# Author: lars.butler@rackspace.com
#install-dependencies.sh
set -euxo pipefail

python --version
pip --version

# The ruamel.yaml.clib package cannot be built in the toolbox container, since there is no GCC present.
#
#     ruamel.yaml.clib==0.2.2; platform_python_implementation == "CPython" and python_version < "3.10"
#
# So, request a known-good (i.e. pinned) binary version

pip install --upgrade --upgrade-strategy only-if-needed --prefer-binary ruamel.yaml.clib==0.2.2
pip install ruamel.yaml==0.17.17

pip install --upgrade fleece[cli]
tfenv install
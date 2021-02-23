#!/usr/bin/env sh
# Copyright 2019-2021 Hewlett Packard Enterprise Development LP
source ./vars.sh

# Set the product name
sed -i s/@product_name@/${NAME}/g kubernetes/cray-uan-install/values.yaml

# Debug
cat kubernetes/cray-uan-install/values.yaml

# Set the cf-gitea-import image version (for the config import)
./update_tags.sh

# Debug
cat Dockerfile.config-framework

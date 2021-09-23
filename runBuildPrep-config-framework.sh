#!/usr/bin/env sh
# Copyright 2019-2021 Hewlett Packard Enterprise Development LP
source ./vars.sh

# Set the cf-gitea-import image version (for the config import)
cf_gitea_import_image_tag="1.4.7"
sed -i s/@cf_gitea_import_image_tag@/${cf_gitea_import_image_tag}/g Dockerfile.config-framework

# Debug
cat Dockerfile.config-framework

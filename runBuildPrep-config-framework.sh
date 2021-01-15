#!/usr/bin/env sh
# Copyright 2019-2021 Hewlett Packard Enterprise Development LP
source ./vars.sh

# Set the product name
sed -i s/@product_name@/${NAME}/g kubernetes/cray-uan-install/values.yaml

# Debug
cat kubernetes/cray-uan-install/values.yaml

# Set the cf-gitea-import image version (for the config import)
wget http://car.dev.cray.com/artifactory/csm/SCMS/noos/noarch/${RELEASE_PREFIX}/${CSM_RELEASE_VERSION}/cms-team/manifest.txt
cf_gitea_import_image_tag=$(cat manifest.txt | grep cf-gitea-import | sed s/.*://g | tr -d '[:space:]')
sed -i s/@cf_gitea_import_image_tag@/${cf_gitea_import_image_tag}/g Dockerfile.config-framework
rm manifest.txt

# Debug
cat Dockerfile.config-framework

#!/usr/bin/env sh
# Copyright 2020-2021 Hewlett Packard Enterprise Development LP
source ./vars.sh

# Set the cray-sles15sp1-uan-cos image version from build time environment variables ($IMG_VER)
sed -i s/CRAY.VERSION.HERE/${IMG_VER}/g images/kiwi-ng/cray-sles15sp1-uan-cos/config-template.xml.j2

# Set the cray-ims-load-artifacts image version
# The URL to the manifest.txt file must be updated to point to the stable manifest when cutting a release branch.
wget https://arti.dev.cray.com/artifactory/csm-misc-master-local/manifest/manifest.txt
ims_load_artifacts_image_tag=$(cat manifest.txt | grep cray-ims-load-artifacts | sed s/.*://g | tr -d '[:space:]')
sed -i s/@ims_load_artifacts_image_tag@/${ims_load_artifacts_image_tag}/g Dockerfile.image-recipe
rm manifest.txt

# Set the product version in the Dockerfile.image-recipe file
sed -i s/@product_version@/${VERSION}/g Dockerfile.image-recipe

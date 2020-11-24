#!/usr/bin/env sh
# Copyright 2020 Hewlett Packard Enterprise Development LP

PRODUCT_VERSION=$(cat uan_product_version)

# Set the cray-sles15sp1-uan-cos image version from build time environment variables ($IMG_VER)
# Use a dev string if building locally and $IMG_VER doesn't exist
BUILD_TS=$(date --utc '+%Y%m%d%H%M%S')
DEV_GIT_HASH="g0000000"
DEV_IMG_VER=$PRODUCT_VERSION-$BUILD_TS-$DEV_GIT_HASH
sed -i s/CRAY.VERSION.HERE/${IMG_VER:-$DEV_IMG_VER}/g images/kiwi-ng/cray-sles15sp1-uan-cos/config-template.xml.j2

# Set the cray-ims-load-artifacts image version
wget http://car.dev.cray.com/artifactory/csm/SCMS/noos/noarch/dev/master/cms-team/manifest.txt
ims_load_artifacts_image_tag=$(cat manifest.txt | grep cray-ims-load-artifacts | sed s/.*://g | tr -d '[:space:]')
sed -i s/@ims_load_artifacts_image_tag@/${ims_load_artifacts_image_tag}/g Dockerfile.image-recipe
rm manifest.txt

# Set the product version in the Dockerfile.image-recipe file
sed -i s/@product_version@/${PRODUCT_VERSION}/g Dockerfile.image-recipe


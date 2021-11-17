#!/usr/bin/env sh
# Copyright 2020-2021 Hewlett Packard Enterprise Development LP
source ./vars.sh

# Set the cray-sles15sp2-uan-cos image version from build time environment variables ($IMG_VER)
sed -i s/CRAY.VERSION.HERE/${IMG_VER}/g images/kiwi-ng/cray-sles15sp2-uan-cos/config-template.xml.j2

ims_load_artifacts_image_tag="1.3.56"
sed -i s/@ims_load_artifacts_image_tag@/${ims_load_artifacts_image_tag}/g Dockerfile.image-recipe

# Set the product version in the Dockerfile.image-recipe file
sed -i s/@product_version@/${VERSION}/g Dockerfile.image-recipe

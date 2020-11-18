#!/bin/bash
#
# Builds OS Image from the Kiwi recipe and packages recipe as tgz
#
# Artifacts that will be packaged up should be placed in /base/build/output
#
# Copyright 2020 Hewlett Packard Enterprise Development LP
set -ex

IMAGE_NAME=cray-shasta-uan-cos-sles15sp1.x86_64-${IMG_VER}

# Setup build directories
mkdir -p /base/build/output /base/build/unpack

# Set the value of the directory of the kiwi description and go there
DESC_DIR=/base/images/kiwi-ng/cray-sles15sp1-uan-cos
cd $DESC_DIR

# Preprocess the Kiwi description config file (for on system use)
scripts/config-process.py \
    --branch $PARENT_BRANCH \
    --input config-template.xml.j2 \
    --output config.xml \
    values-shasta.yaml.j2

cat config.xml

# Preprocess the Zypper configuration file for the image (for on system use)
mkdir -p $DESC_DIR/root/root/bin
scripts/config-process.py \
    --branch $PARENT_BRANCH \
    --input zypper-addrepo.sh.j2 \
    --output root/root/bin/zypper-addrepo.sh \
    values-shasta.yaml.j2
chmod 755 root/root/bin/zypper-addrepo.sh

# Package up the recipe after file templating is complete.
# 'recipe' must be in the name for it to be captured by the script that creates
# the import manifest for IMS.
tar -C $DESC_DIR -zcvf /base/build/output/${IMAGE_NAME}-recipe.tgz --exclude=*.j2  --exclude=scripts *
tar -ztvf /base/build/output/${IMAGE_NAME}-recipe.tgz

# Preprocess the Kiwi description config file for the prebuilt image
rm config.xml
scripts/config-process.py \
    --branch $PARENT_BRANCH \
    --input config-template.xml.j2 \
    --output config.xml \
    values-cje.yaml.j2

cat config.xml

# Build OS image with Kiwi NG (add --debug for lots 'o output)
time /usr/bin/kiwi-ng --type tbz system build --description $DESC_DIR --target-dir /build/output

# Build squashfs from OS image tarball and place in /base/build/output for
# packaging in later pipeline steps.
cd /base/build/unpack
TARBALL=$(echo /build/output/*.tar.xz)
time tar --extract --xz --numeric --file $TARBALL
time mksquashfs . ${IMAGE_NAME}.squashfs -comp xz -no-progress
cp ${IMAGE_NAME}.squashfs /base/build/output/

# Copy kernel and initrd to output directory
cp boot/initrd  /base/build/output/${IMAGE_NAME}.initrd
cp boot/vmlinuz /base/build/output/${IMAGE_NAME}.vmlinuz

# For the UAN, we don't need to deliver the tar.xz version. Remove it to
# save space in the docker image that delivers the image to the system.
rm /base/build/output/*.tar.xz


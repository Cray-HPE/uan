#!/usr/bin/env sh
# Copyright 2020 Hewlett Packard Enterprise Development LP

# Build the UAN COS-based image, this is done in the pipeline, hence the
# /base directory prefix. See the pipeline definition here:
#   https://stash.us.cray.com/projects/DST/repos/jenkins-shared-library/browse/vars/kiwiImageRecipeBuildPipeline.groovy

/base/images/kiwi-ng/cray-sles15sp2-uan-cos/scripts/kiwi-image-build.sh

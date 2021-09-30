# Copyright 2020-2021 Hewlett Packard Enterprise Development LP
# Name and Version Information for the User Access Node Distribution
export NAME="uan"

# For developing for a release distribution, use ${VERSION} here.
#  - List versions of dependencies here as well
export RELEASE_PREFIX="release"
export RELEASE_VERSION="shasta-1.4"
export SLINGSHOT_RELEASE_VERSION="shasta-1.4"
export CSM_RELEASE_VERSION="shasta-1.4"
export COS_RELEASE_VERSION="shasta-1.4"

# Artifact Bloblet Locations for UAN and its dependencies
export BLOBLET_UAN="https://artifactory.algol60.net/artifactory/uan-rpms/hpe/stable"
export BLOBLET_SLINGSHOT="http://dst.us.cray.com/dstrepo/bloblets/slingshot/${RELEASE_PREFIX}/${SLINGSHOT_RELEASE_VERSION}"
export BLOBLET_CSM="http://dst.us.cray.com/dstrepo/bloblets/csm/${RELEASE_PREFIX}/${CSM_RELEASE_VERSION}"
export BLOBLET_COS="http://dst.us.cray.com/dstrepo/bloblets/cos/${RELEASE_PREFIX}/${COS_RELEASE_VERSION}"
export BLOBLET_OS="http://dst.us.cray.com/dstrepo/bloblets/os/dev/mirrors"

# Version of the cf-gitea-import Docker Image to Use
export cf_gitea_import_image_tag=1.0.10

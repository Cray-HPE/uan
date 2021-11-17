# Copyright 2020-2021 Hewlett Packard Enterprise Development LP
# Name and Version Information for the User Access Node Distribution
export NAME="uan"

# For developing for a master distribution, use 'master' here.
#  - List versions of dependencies here as well
export RELEASE_PREFIX="release"
export RELEASE_VERSION="uan-2.1"
export SLINGSHOT_RELEASE_VERSION="cos-2.1"
export CSM_RELEASE_VERSION="csm-1.0"
export COS_RELEASE_VERSION="cos-2.1"

# Artifact Bloblet Locations for UAN and its dependencies
export BLOBLET_UAN="https://artifactory.algol60.net/artifactory/uan-rpms/hpe/stable"
export BLOBLET_SLINGSHOT="http://dst.us.cray.com/dstrepo/bloblets/slingshot-host-software/${RELEASE_PREFIX}/${SLINGSHOT_RELEASE_VERSION}"
export BLOBLET_CSM="http://dst.us.cray.com/dstrepo/bloblets/csm/${RELEASE_PREFIX}/${CSM_RELEASE_VERSION}"
export BLOBLET_COS="http://dst.us.cray.com/dstrepo/bloblets/cos/${RELEASE_PREFIX}/${COS_RELEASE_VERSION}"
export BLOBLET_OS="http://dst.us.cray.com/dstrepo/bloblets/os/dev/mirrors"

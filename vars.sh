# Copyright 2020-2021 Hewlett Packard Enterprise Development LP
# Name and Version Information for the User Access Node Distribution
export NAME="uan"

# For developing for a master distribution, use 'master' here.
#  - List versions of dependencies here as well
export RELEASE_PREFIX="dev"
export RELEASE_VERSION="master"
export SLINGSHOT_RELEASE_VERSION="master"
export CSM_RELEASE_VERSION="master"
export COS_RELEASE_VERSION="master"

# Artifact Bloblet Locations for UAN and its dependencies
export BLOBLET_UAN="http://dst.us.cray.com/dstrepo/bloblets/${NAME}/${RELEASE_PREFIX}/${RELEASE_VERSION}"
export BLOBLET_SLINGSHOT="http://dst.us.cray.com/dstrepo/bloblets/slingshot-host-software/${RELEASE_PREFIX}/${SLINGSHOT_RELEASE_VERSION}"
export BLOBLET_CSM="http://dst.us.cray.com/dstrepo/bloblets/csm/${RELEASE_PREFIX}/${CSM_RELEASE_VERSION}"
export BLOBLET_COS="http://dst.us.cray.com/dstrepo/bloblets/cos/${RELEASE_PREFIX}/${COS_RELEASE_VERSION}"
export BLOBLET_OS="http://dst.us.cray.com/dstrepo/bloblets/os/dev/mirrors"

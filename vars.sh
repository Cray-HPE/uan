# Copyright 2020 Hewlett Packard Enterprise Development LP
# Name and Version Information for the User Access Node Distribution
export NAME="uan"
export VERSION="2.0.0"

export MAJOR=`echo ${VERSION} | cut -d. -f1`
export MINOR=`echo ${VERSION} | cut -d. -f2`
export PATCH=`echo ${VERSION} | cut -d. -f3`

# For developing for a release distribution, use ${VERSION} here.
#  - List versions of dependencies here as well
export RELEASE_PREFIX="release"
export RELEASE_VERSION="shasta-1.4"
export CSM_RELEASE_VERSION="shasta-1.4"
export COS_RELEASE_VERSION="shasta-1.4"

# Artifact Bloblet Locations for UAN and its dependencies
export BLOBLET_UAN="http://dst.us.cray.com/dstrepo/bloblets/${NAME}/${RELEASE_PREFIX}/${RELEASE_VERSION}"
export BLOBLET_CSM="http://dst.us.cray.com/dstrepo/bloblets/csm/${RELEASE_PREFIX}/${CSM_RELEASE_VERSION}"
export BLOBLET_COS="http://dst.us.cray.com/dstrepo/bloblets/cos/${RELEASE_PREFIX}/${COS_RELEASE_VERSION}"
export BLOBLET_OS="http://dst.us.cray.com/dstrepo/bloblets/os/dev/mirrors"

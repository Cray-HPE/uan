# Copyright 2020 Hewlett Packard Enterprise Development LP
# Name and Version Information for the User Access Node Distribution
export NAME="uan"
export VERSION="2.0.0"

export MAJOR=`echo ${VERSION} | cut -d. -f1`
export MINOR=`echo ${VERSION} | cut -d. -f2`
export PATCH=`echo ${VERSION} | cut -d. -f3`

# For developing for a master distribution, use 'master' here.
# For developing for a release distribution, use ${VERSION} here.
#  - ${PARENT_BRANCH} comes from the DST pipeline
#  - List versions of dependencies here as well
if [ ${PARENT_BRANCH:-master} == "master" ]
then
    export RELEASE_VERSION="master"
    export CSM_RELEASE_VERSION="master"
    export COS_RELEASE_VERSION="master"
else
    export RELEASE_VERSION=${VERSION}
    export CSM_RELEASE_VERSION="1.4"
    export COS_RELEASE_VERSION="1.4"
fi

# DST prefixes in bloblet locations
if [ ${RELEASE_VERSION} == "master" ]
then
    export RELEASE_PREFIX="dev"
else
    export RELEASE_PREFIX="release"
fi

# Artifact Bloblet Locations for UAN and its dependencies
export BLOBLET_UAN="http://dst.us.cray.com/dstrepo/bloblets/${NAME}/${RELEASE_PREFIX}/${RELEASE_VERSION}"
export BLOBLET_CSM="http://dst.us.cray.com/dstrepo/bloblets/csm/${RELEASE_PREFIX}/${CSM_RELEASE_VERSION}"
export BLOBLET_COS="http://dst.us.cray.com/dstrepo/bloblets/cos/${RELEASE_PREFIX}/${COS_RELEASE_VERSION}"
export BLOBLET_OS="http://dst.us.cray.com/dstrepo/bloblets/os/dev/mirrors"

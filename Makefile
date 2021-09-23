# Copyright 2019-2021 Hewlett Packard Enterprise Development LP
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
# (MIT License)

NAME_RECIPE_IMAGE ?= cray-uan-image-recipe
NAME_CONFIG_IMAGE ?= cray-uan-config
VERSION ?= $(shell cat .version)-local
export VERSION

PRODUCT_VERSION ?= uan-2.1
BUILD_DATE ?= $(shell date +'%Y%m%d%H%M%S')
GIT_BRANCH ?= local
GIT_TAG ?= $(shell git rev-parse --short HEAD)
IMG_VER ?= ${PRODUCT_VERSION}-${BUILD_DATE}-g${GIT_TAG}
export IMG_VER

IMAGE_NAME ?= cray-shasta-uan-cos-sles15sp2.x86_64
DISTRO ?= sles15

DOCKERFILE_IMAGE ?= Dockerfile.image-recipe
DOCKERFILE_CONFIG ?= Dockerfile.config-framework
BUILD_IMAGE ?= arti.dev.cray.com/cos-docker-master-local/cray-kiwi:latest
BUILD_SCRIPT ?= runKiwiBuild.sh
RECIPE_DIRECTORY ?= images/kiwi-ng/cray-sles15sp2-uan-cos

CHART_NAME ?= cray-uan-install
CHART_PATH ?= kubernetes
CHART_VERSION ?= local
HELM_UNITTEST_IMAGE ?= quintush/helm-unittest:3.3.0-0.2.5

all : kiwi_image config_docker_image chart
kiwi_image: kiwi_build_prep kiwi_build_image kiwi_build_manifest kiwi_docker_image
config_image: config_docker_image
chart: chart_setup chart_package chart_test

kiwi_build_prep:
	docker run -v ${PWD}:/base \
		${BUILD_IMAGE}
		rm -rf /base/build
	echo "IMG_VER: ${IMG_VER}"
	sh ./runBuildPrep-image-recipe.sh

kiwi_build_image:
	docker run --rm --privileged \
		-e PARENT_BRANCH=${GIT_BRANCH} -e PRODUCT_VERSION=${PRODUCT_VERSION} \
		-e IMG_VER=${IMG_VER} -e BUILD_DATE=${BUILD_DATE} -e GIT_TAG=${GIT_TAG} \
		-v ${PWD}/build:/build -v ${PWD}:/base \
		${BUILD_IMAGE} \
		/bin/bash /base/${BUILD_SCRIPT} ${RECIPE_DIRECTORY}

kiwi_build_manifest:
	$(eval FILES := $(shell find build/output/* -maxdepth 0 | tr '\r\n' ' ' ))

	docker run --rm --privileged \
		-e PARENT_BRANCH=${GIT_BRANCH} -e PRODUCT_VERSION=${PRODUCT_VERSION} \
		-e IMG_VER=${IMG_VER} -e BUILD_TS=${BUILD_DATE} -e GIT_TAG=${GIT_TAG} \
		-v ${PWD}/build:/build -v ${PWD}:/root \
		--workdir /root \
		${BUILD_IMAGE} \
		bash -c 'ls -al /build && pwd && python3 create_init_ims_manifest.py --distro "${DISTRO}" --files "${FILES}" ${IMAGE_NAME}-${PRODUCT_VERSION}'

	cat manifest.yaml

kiwi_docker_image:
	DOCKER_BUILDKIT=1 docker build --pull ${DOCKER_ARGS} -f ${DOCKERFILE_IMAGE} --tag '${NAME_RECIPE_IMAGE}:${VERSION}' .

config_docker_image:
	./runBuildPrep-config-framework.sh
	docker build --pull ${DOCKER_ARGS} -f ${DOCKERFILE_CONFIG} --tag '${NAME_CONFIG_IMAGE}:${VERSION}' .

chart_setup:
	mkdir -p ${CHART_PATH}/.packaged
	printf "\nglobal:\n  appVersion: ${VERSION}" >> ${CHART_PATH}/${CHART_NAME}/values.yaml

chart_package:
	helm dep up ${CHART_PATH}/${CHART_NAME}
	helm package ${CHART_PATH}/${CHART_NAME} -d ${CHART_PATH}/.packaged --app-version ${VERSION} --version ${CHART_VERSION}

chart_test:
	helm lint "${CHART_PATH}/${CHART_NAME}"
	docker run --rm -v ${PWD}/${CHART_PATH}:/apps ${HELM_UNITTEST_IMAGE} -3 ${CHART_NAME}

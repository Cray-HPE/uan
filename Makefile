#
# MIT License
#
# (C) Copyright 2019-2022 Hewlett Packard Enterprise Development LP
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
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
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

NAME_CONFIG_IMAGE ?= cray-uan-config
VERSION ?= $(shell cat .version)-local
export VERSION

BUILD_DATE ?= $(shell date +'%Y%m%d%H%M%S')
GIT_BRANCH ?= local
GIT_TAG ?= $(shell git rev-parse --short HEAD)

DOCKERFILE_CONFIG ?= Dockerfile.config-framework

CHART_NAME ?= cray-uan-install
CHART_PATH ?= kubernetes
CHART_VERSION ?= local
HELM_UNITTEST_IMAGE ?= quintush/helm-unittest:3.3.0-0.2.5

all : test_docker_image config_docker_image chart
config_image: config_docker_image
chart: chart_setup chart_package chart_test

config_docker_image:
	docker build --pull ${DOCKER_ARGS} -f ${DOCKERFILE_CONFIG} --tag '${NAME_CONFIG_IMAGE}:${VERSION}' .

test_docker_image:
	docker build --pull ${DOCKER_ARGS} -f ${DOCKERFILE_CONFIG} --progress=plain --target testing .

chart_setup:
	mkdir -p ${CHART_PATH}/.packaged
	printf "\nglobal:\n  appVersion: ${VERSION}" >> ${CHART_PATH}/${CHART_NAME}/values.yaml

chart_package:
	helm dep up ${CHART_PATH}/${CHART_NAME}
	helm package ${CHART_PATH}/${CHART_NAME} -d ${CHART_PATH}/.packaged --app-version ${VERSION} --version ${CHART_VERSION}

chart_test:
	helm lint "${CHART_PATH}/${CHART_NAME}"
	docker run --rm -v ${PWD}/${CHART_PATH}:/apps ${HELM_UNITTEST_IMAGE} -3 ${CHART_NAME}

#!/bin/bash
# Copyright 2019-2020 Hewlett Packard Enterprise Development LP
#
# Add repo for build macros
zypper ar --no-gpgcheck --refresh http://car.dev.cray.com/artifactory/shasta-premium/SHASTA-OS/sle15_sp1_ncn/x86_64/dev/master/ shasta-os-build-resource

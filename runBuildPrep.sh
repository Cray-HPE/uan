#!/bin/bash

# Add repo for build macros
zypper ar --no-gpgcheck --refresh http://car.dev.cray.com/artifactory/shasta-premium/SHASTA-OS/sle15_sp1_ncn/x86_64/release/shasta-1.3/ shasta-os-build-resource

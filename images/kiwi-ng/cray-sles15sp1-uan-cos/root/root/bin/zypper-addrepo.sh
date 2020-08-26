#!/bin/bash
#
# Copyright 2019-2020 Hewlett Packard Enterprise Development LP
#

set -ex



zypper addrepo --priority 2 http://packages.local/repository/cos-1.3-sle-15sp1-compute/ cos-1.3-sle-15sp1-compute



zypper addrepo --priority 2 http://packages.local/repository/sma-1.3-sle-15sp1-compute/ sma-1.3-sle-15sp1-compute



zypper addrepo --priority 3 http://packages.local/repository/mirror-1.3-sle-15sp1-all-products/ mirror-1.3-sle-15sp1-all-products



zypper addrepo --priority 3 http://packages.local/repository/mirror-1.3-sle-15sp1-all-updates/ mirror-1.3-sle-15sp1-all-updates



exit 0

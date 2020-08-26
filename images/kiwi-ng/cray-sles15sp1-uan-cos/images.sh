#!/bin/bash
#
# Copyright 2019-2020 Hewlett Packard Enterprise Development LP
#

set -e

echo "Generating initrd..."

# Query installed rpm to get kernel version.
kernel_rpm=$(rpm --query --queryformat "%{VERSION}-%{RELEASE}\n" kernel-cray_shasta_c)
num=$(echo "$kernel_rpm" | wc -l)
if [[ $num -ne 1 ]]; then
    echo "There should be exactly one kernel RPM installed ... aborting build"
    exit 1
fi

version=$(echo "$kernel_rpm" | awk -F_ '{ print $1 "_" $2 }')
premium_version="${version}-cray_shasta_c"

# Let's check for a known module to ensure we are using a complete kernel install
mypath="/lib/modules/${premium_version}/kernel/net/sunrpc/sunrpc.ko"

echo "PREMIUM VERSION  : ${premium_version}"
echo "LIB MODULES PATH : $mypath"

# Bail if kernel module not found
if [[ ! -e $mypath ]]; then
    echo "Unable to validate presence of kernel modules directory ... aborting build"
    exit 1
fi

dvs_tg=$(find /opt/cray/dvs -name dvs_thread_generator -print)
num=$(echo "$dvs_tg" | wc -l)
if [[ $num -ne 1 ]]; then
    echo "There should be exactly one dvs_thread_generator in /opt/cray/dvs"
    exit 1
fi

initrd_add="\
craycps \
craydvs \
crayfs \
craylnet \
craytokens \
crayurl \
network \
nfs \
"

initrd_install="\
/etc/dvs_node_map.conf \
/etc/lnet.conf \
/etc/modprobe.d/cray-sunrpc.conf \
/etc/modprobe.d/dvs.conf \
/etc/modprobe.d/lnet.conf \
/opt/cray/cps-utils/bin/cpsmount.sh \
$dvs_tg \
/usr/bin/awk \
/usr/bin/chmod \
/usr/bin/curl \
/usr/bin/date \
/usr/bin/expr \
/usr/bin/getopt \
/usr/bin/grep \
/usr/bin/host \
/usr/bin/jq \
/usr/bin/sed \
/usr/bin/sleep \
/usr/bin/wc \
/usr/sbin/lnetctl \
"

dracut \
--add "${initrd_add}" \
--force \
--install "${initrd_install}" \
--kver ${premium_version} \
--no-hostonly \
--no-hostonly-cmdline \
--xz \
/boot/initrd-${premium_version}

exit 0

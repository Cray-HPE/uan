#!/bin/bash
set -e +xv
trap "rm -rf /root/.zypp" EXIT

ARTIFACTORY_USERNAME=$(test -f /run/secrets/ARTIFACTORY_READONLY_USER && cat /run/secrets/ARTIFACTORY_READONLY_USER)
ARTIFACTORY_PASSWORD=$(test -f /run/secrets/ARTIFACTORY_READONLY_TOKEN && cat /run/secrets/ARTIFACTORY_READONLY_TOKEN)
ALGOL="https://${ARTIFACTORY_USERNAME:-}${ARTIFACTORY_PASSWORD+:}${ARTIFACTORY_PASSWORD}@artifactory.algol60.net/artifactory"
SLES_VERSION=15-SP3
ARCH=x86_64
zypper --non-interactive ar ${ALGOL}/uan-rpms/hpe/stable/sle-15sp3?auth=basic uan-rpms
zypper update -y
zypper install -y iptables\
                  sysconfig \
                  vim

# Running ansible-playbook with --syntax-check
ansible-playbook /opt/cray/ansible/site.yml --connection=local --syntax-check

# Running ansible-playbook with --check and cray_cfs_image=true to simulate CFS image customization
ansible-playbook /opt/cray/ansible/site.yml --connection=local -e cray_cfs_image=true  --check

# Running ansible-playbook with --check and cray_cfs_image=false to simulate CFS node personalization
ansible-playbook /opt/cray/ansible/site.yml --connection=local -e cray_cfs_image=false --check

# Remove repos
zypper clean -a && zypper --non-interactive rr --all && rm -f /etc/zypp/repos.d/*

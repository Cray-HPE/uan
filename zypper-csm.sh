#!/bin/bash
set -e +xv
trap "rm -rf /root/.zypp" EXIT

ARTIFACTORY_USERNAME=$(test -f /run/secrets/ARTIFACTORY_READONLY_USER && cat /run/secrets/ARTIFACTORY_READONLY_USER)
ARTIFACTORY_PASSWORD=$(test -f /run/secrets/ARTIFACTORY_READONLY_TOKEN && cat /run/secrets/ARTIFACTORY_READONLY_TOKEN)
ALGOL="https://${ARTIFACTORY_USERNAME:-}${ARTIFACTORY_PASSWORD+:}${ARTIFACTORY_PASSWORD}@artifactory.algol60.net/artifactory"
CSM_SLES_VERSION=sle-15sp3
zypper --non-interactive ar --no-gpgcheck ${ALGOL}/csm-rpms/hpe/stable/${CSM_SLES_VERSION}?auth=basic csm-rpms
zypper update -y
zypper install -y cf-ca-cert-config-framework \
                  csm-ssh-keys-1.3.79-1.noarch \
                  csm-ssh-keys-roles-1.3.79-1.noarch

# Remove repos
zypper clean -a && zypper --non-interactive rr --all && rm -f /etc/zypp/repos.d/*

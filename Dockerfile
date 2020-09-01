# Dockerfile for importing UAN content into gitea instances on Shasta
# Copyright 2020 Hewlett Packard Enterprise Development LP
FROM dtr.dev.cray.com/baseos/sles15sp1 as product-content-base
WORKDIR /

# Install dependencies as RPMs
RUN zypper ar --no-gpgcheck http://car.dev.cray.com/artifactory/shasta-premium/NWMGMT/sle15_sp1_ncn/x86_64/dev/master    shasta-ncmp && \
    zypper ar --no-gpgcheck http://car.dev.cray.com/artifactory/shasta-premium/CRAYCTL/sle15_sp1_ncn/x86_64/dev/master   shasta-dst  && \
    zypper ar --no-gpgcheck http://car.dev.cray.com/artifactory/shasta-premium/SCMS/sle15_sp1_ncn/x86_64/dev/master      shasta-scms && \
    zypper ar --no-gpgcheck http://car.dev.cray.com/artifactory/shasta-premium/SHASTA-OS/sle15_sp1_ncn/x86_64/dev/master shasta-cos  && \
    zypper ar --no-gpgcheck http://car.dev.cray.com/artifactory/shasta-premium/RM/sle15_sp1_ncn/x86_64/dev/master        shasta-rm   && \
    zypper ar --no-gpgcheck http://car.dev.cray.com/artifactory/shasta-premium/LUS/sle15_sp1_ncn/x86_64/dev/master       shasta-lus  && \
    zypper ar --no-gpgcheck http://car.dev.cray.com/artifactory/shasta-premium/DVS/sle15_sp1_ncn/x86_64/dev/master       shasta-dvs  && \
    zypper refresh && \
    zypper in -y \
        slurm-config-framework \
        pbs-config-framework \
        cf-cme-sysconfig-config-framework \
        cf-cme-overlay-preload-config-framework \
        cf-ca-cert-config-framework \
        cf-cme-ncmp-hsn-config-framework \
        nms-config-framework \
        lustre-cfs-config-framework \
        cray-dvs-helper-config-framework \
        cray-lnet-helper-config-framework

# Use the cf-gitea-import as a base image with UAN content copied in
FROM dtr.dev.cray.com/cray/cf-gitea-import:@cf_gitea_import_image_tag@

# Use for testing/not in pipeline builds
#FROM dtr.dev.cray.com/cray/cf-gitea-import:latest 

WORKDIR /
ENV CF_IMPORT_PRODUCT_NAME=uan
ADD uan_product_version /product_version

# Copy in dependencies' Ansible content
COPY --from=product-content-base /opt/cray/ansible/roles/      /content/roles/
COPY --from=product-content-base /opt/cray/ansible/playbooks/ /content/playbooks/

# Copy in UAN Ansible content
COPY ansible/ /content/

# Base image entrypoint takes it from here
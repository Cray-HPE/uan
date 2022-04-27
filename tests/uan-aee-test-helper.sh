#!/bin/sh
#
# MIT License
#
# (C) Copyright 2022 Hewlett Packard Enterprise Development LP
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

# Write out an ansible hosts file for testing
cat << EOF > /etc/ansible/hosts 
[Application_UAN]
localhost
EOF

# Write out an ansible group_var file for testing
mkdir -p /opt/cray/ansible/group_vars/Application_UAN
cat << EOF > /opt/cray/ansible/group_vars/Application_UAN/test.yml
csm_public_key_test: {
    'response': '0xB105F00D'
  }
root_passwd: 'notarealpassword'

hpe_gpg_pubkey_test: {
    'response': '0xC00010FF'
}
temp_key_file_test: {
    'path': '/hpe_gpg_signing_key'
}

uan_vault_url: "http://localhost:8200"
uan_vault_role_file: /tmp/namespace
uan_vault_jwt_file: /tmp/token

uan_motd_content: "MOTD goes here"

filesystems:
  - src: 127.0.0.1:/fakelus
    mount_point: /lus
    fstype: nfs4
    opts: rw
    state: mounted

sls_cab_test:
  'status': 200
  'json': 
     - "Parent": "s0"
       "Children":
         - "x3000c0r40b0"
         - "x3000c0r39b0"
         - "x3000m0"
         - "x3000m1"
       "Xname": "x3000"
       "Type": "comptype_cabinet"
       "Class": "River"
       "TypeString": "Cabinet"
       "LastUpdated": 1648068726
       "LastUpdatedTime": "2022-03-23 20:52:06.162352 +0000 +0000"
       "ExtraProperties":
          "Networks":
            "cn":
              "HMN":
                "CIDR": "10.107.0.0/22"
                "Gateway": "10.107.0.1"
                "VLan": 1513
              "NMN":
                "CIDR": "10.106.0.0/22"
                "Gateway": "10.106.0.1"
                "VLan": 1770
            "ncn": 
              "HMN":
                "CIDR": "10.107.0.0/22"
                "Gateway": "10.107.0.1"
                "VLan": 1513
              "NMN":
                "CIDR": "10.106.0.0/22"
                "Gateway": "10.106.0.1"
                "VLan": 1770
     - "Parent": "s0"
       "Children":
         - "x1000c5"
         - "x1000c1"
         - "x1000c4"
         - "x1000c0"
         - "x1000c3"
         - "x1000c2"
         - "x1000c7"
         - "x1000c6"
       "Xname": "x1000"
       "Type": "comptype_cabinet"
       "Class": "Mountain"
       "TypeString": "Cabinet"
       "LastUpdated": 1648068726
       "LastUpdatedTime": "2022-03-23 20:52:06.162352 +0000 +0000"
       "ExtraProperties":
         "Networks":
           "cn":
             "HMN":
               "CIDR": "10.104.0.0/22"
               "VLan": 3000
             "NMN":
               "CIDR": "10.100.0.0/22"
               "Gateway": "10.100.0.1"
               "VLan": 2000
               
sls_bican_test:
  "status": 200
  "json":
    - "ExtraProperties":
        "SystemDefaultRoute": "CHN"
EOF

# This is a meaningless PGP public key, it will not work for checking
echo "-----BEGIN PGP PUBLIC KEY BLOCK-----

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
=3P9w
-----END PGP PUBLIC KEY BLOCK-----" > /hpe_gpg_signing_key

echo "test_namespace" > /tmp/namespace
echo "test_token" > /tmp/token

# Increase logging
sed -i 's/^display_ok_hosts      = no/display_ok_hosts      = yes/g' /etc/ansible/ansible.cfg
#sed -i 's/^display_skipped_hosts = no/display_skipped_hosts = yes/g' /etc/ansible/ansible.cfg

# Do some massaging of a few tasks that require vars be defined. It seems that check mode will
# unset some vars if previous tasks in check mode write to the register. That is why the test.yml
# file writes some vars with a "_test" suffix
sed -i 's/csm_public_key\[/csm_public_key_test\[/g' /opt/cray/ansible/roles/trust-csm-ssh-keys/tasks/main.yaml
sed -i 's/hpe_gpg_pubkey\./hpe_gpg_pubkey_test\./g' /opt/cray/ansible/roles/uan_packages/tasks/main.yml
sed -i 's/temp_key_file\./temp_key_file_test\./g' /opt/cray/ansible/roles/uan_packages/tasks/main.yml
sed -i 's/sls_cab\./sls_cab_test\./g' /opt/cray/ansible/roles/uan_interfaces/tasks/main.yml
sed -i 's/sls_bican\./sls_bican_test\./g' /opt/cray/ansible/roles/uan_interfaces/tasks/main.yml

# Add dummy files for ca-cert role
mkdir -p /etc/cray/ca
touch /etc/cray/ca/certificate_authority.crt
mkdir -p /var/run/secrets/kubernetes.io/serviceaccount/
touch /var/run/secrets/kubernetes.io/serviceaccount/token
touch /var/run/secrets/kubernetes.io/serviceaccount/namespace

# This file would exist in an image that was run with CFS image customization
touch /etc/modprobe.d/dvs.conf

# Running ansible-playbook with --syntax-check
#ansible-playbook /opt/cray/ansible/site.yml --connection=local --syntax-check

# Running ansible-playbook with --check and cray_cfs_image=true to simulate CFS image customization
#ansible-playbook /opt/cray/ansible/site.yml --connection=local -e cray_cfs_image=true  --check

# Running ansible-playbook with --check and cray_cfs_image=false to simulate CFS node personalization
#ansible-playbook /opt/cray/ansible/site.yml --connection=local -e cray_cfs_image=false --check

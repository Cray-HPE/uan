uan_ldap
=========

The `uan_ldap` role configures LDAP and AD groups on UAN nodes.

Requirements
------------

NSCD, pam-config, sssd.

Role Variables
--------------

Available variables are listed below, along with default values (see defaults/main.yml):

`uan_ldap_setup` is a boolean variable to selectively skip the setup of LDAP on nodes it
would otherwise be configured due to `uan_ldap_config` being defined.  The default setting
is to setup LDAP when `uan_ldap_config` is not empty.

```yaml
uan_ldap_setup: yes
```

`uan_ldap_config` configures LDAP domains and servers. If this list is empty,
no LDAP configuration will be applied to the UAN targets and all role tasks will
be skipped.

```yaml
uan_ldap_config: []

# Example
uan_ldap_config:
  - domain: "mydomain-ldaps"
    search_base: "dc=...,dc=..."
    servers: ["ldaps://123.123.123.1", "ldaps://213.312.123.132"]
    chpass_uri: ["ldaps://123.123.123.1"]

  - domain: "mydomain-ldap"
    search_base: "dc=...,dc=..."
    servers: ["ldap://123.123.123.1", "ldap://213.312.123.132"]

```

`uan_ad_groups` configures active directory groups on UAN nodes.

```yaml
uan_ad_groups: []

# Example
uan_ad_groups:
  - { name: admin_grp, origin: ALL }
  - { name: dev_users, origin: ALL }
```

`uan_pam_modules` configures PAM modules on the UAN nodes in `/etc/pam.d`.

```yaml
uan_pam_modules: []

# Example
uan_pam_modules:
  - name: "common-account"
    lines:
      - "account required\tpam_access.so"
```
Sensitive Role Variables
------------------------

Any sssd.conf variables which are sensitive in nature should be stored in the secret/uan_ldap hashicorp vault path using the
variable name as the key.

To use these sensitive variables in sssd.conf, list them in the `uan_ldap_keys` list and they will be set in the `[domain]` section
of sssd.conf.

```yaml
uan_ldap_keys: []
```

# Example
```yaml
uan_ldap_keys: [ "ldap_default_authtok" ]
```

### `uan_vault_url`

`uan_vault_url` is the URL for the HashiCorp Vault

```yaml
uan_vault_url: "http://cray-vault.vault:8200"
```

### `uan_vault_role_file`

`uan_vault_role_file` is the required Kubernetes role file for HashiCorp Vault access.

```yaml
uan_vault_role_file: /var/run/secrets/kubernetes.io/serviceaccount/namespace
```

### `uan_vault_jwt_file`

`uan_vault_jwt_file` is the path to the required Kubernetes token file for HashiCorp Vault access.

```yaml
uan_vault_jwt_file: /var/run/secrets/kubernetes.io/serviceaccount/token
```

### `uan_vault_path`

`uan_vault_path` is the path to use for storing uan_ldap data for UANs in HashiCorp Vault.

```yaml
uan_vault_path: secret/uan_ldap
```

Dependencies
------------

None.

Example Playbook
----------------

```yaml
- hosts: Application_UAN
  roles:
      - { role: uan_ldap }
```

This role is included in the UAN `site.yml` play.

License
-------

MIT License

(C) Copyright [2019-2021] Hewlett Packard Enterprise Development LP

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

Author Information
------------------

Hewlett Packard Enterprise Development LP

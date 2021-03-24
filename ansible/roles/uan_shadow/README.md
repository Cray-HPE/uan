uan_shadow
==========

The `uan_shadow` role configures the root password on UAN nodes.

Requirements
------------

The root password hash has to be installed in HashiCorp Vault at `secret/uan root_password`.

Role Variables
--------------

Available variables are listed below, along with default values (see defaults/main.yml):

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

`uan_vault_path` is the path to use for storing data for UANs in HashiCorp Vault.

```yaml
uan_vault_path: secret/uan
```

### `uan_vault_key`

`uan_vault_key` is the key used for storing the root password in HashiCorp Vault.

```yaml
uan_vault_key: root_password
```

Dependencies
------------

None.

Example Playbook
----------------

```yaml
- hosts: Application_UAN
  roles:
      - { role: uan_shadow }
```

This role is included in the UAN `site.yml` play.

License
-------

Copyright 2019-2021 Hewlett Packard Enterprise Development LP

Author Information
------------------

Hewlett Packard Enterprise Development LP
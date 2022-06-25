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

MIT License

(C) Copyright [2022] Hewlett Packard Enterprise Development LP

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

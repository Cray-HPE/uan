uan_gpg_keys
=========

Install the CSM GPG signing public key. This role is a dependency of the
`uan_packages` role.

Requirements
------------

The Kubernetes secret must be available in the namespace and field specified
by the `uan_gpg_key_*` variables below. The key must be stored as a base64-encoded
string.

Role Variables
--------------

Available variables are listed below, along with default values (located in
`defaults/main.yml`):

    uan_gpg_key_k8s_secret: "hpe-signing-key"

The Kubernetes secret which contains the GPG public key.

    uan_gpg_key_k8s_namespace: "services"

The Kubernetes namespace which contains the secret.

    uan_gpg_key_k8s_field: "gpg-pubkey"

The field in the Kubernetes secret that holds the GPG public key.

Dependencies
------------

None.

Example Playbook
----------------

    - hosts: Application
      roles:
         - role: uan_gpg_key


License
-------

MIT

Author Information
------------------

Copyright 2022 Hewlett Packard Enterprise Development LP

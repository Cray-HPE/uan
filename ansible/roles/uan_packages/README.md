uan_packages
=========

The `uan_packages` role installs additional RPMs on UANs using the Ansible
`zypper` module.

Packages that are required for UANs to function should be preferentially
installed during image customization and/or image creation.

Installing RPMs during post-boot node configuration can cause high system loads
on large systems.

This role will only run on SLES-based nodes.

Requirements
------------

Zypper must be installed.

Role Variables
--------------

Available variables are listed below, along with default values (see defaults/main.yml):

```yaml
uan_additional_sles15_packages: []
```

`uan_additional_sles15_packages` contains the list of RPM packages to install.

Dependencies
------------

None.

Example Playbook
----------------

```yaml
- hosts: Application_UAN
  roles:
      - { role: uan_packages, uan_additional_sles15_packages: ['vim'] }
```

This role is included in the UAN `site.yml` play.

License
-------

Copyright 2020-2021 Hewlett Packard Enterprise Development LP

Author Information
------------------

Hewlett Packard Enterprise Development LP

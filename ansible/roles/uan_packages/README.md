uan_packages
=========

The `uan_packages` role adds or removes additional repositories and RPMs on UANs
using the Ansible `zypper_repository` and `zypper` module.

Repositories and packages added to this role will be installed or removed during
image customization. Installing RPMs during post-boot node configuration can
cause high system loads on large systems so these tasks runs only during image
customizations.

This role will only run on SLES-based nodes.

Requirements
------------

Zypper must be installed.

Role Variables
--------------

Available variables are listed below, along with default values (see defaults/main.yml):

```yaml
uan_sles15_repositories_add:[]
uan_sles15_packages_add:[]
uan_sles15_packages_remove:[]
```

This role uses the `zypper_repository` module. The `name`, `description`, `url`, and
`priority` fields are supported.

`uan_sles15_repositories_add` contains the list of repositories to add.
`uan_sles15_packages_add` contains the list of RPM packages to add.

Dependencies
------------

None.

Example Playbook
----------------

```yaml
- hosts: Application_UAN
  roles:
     - role: uan_packages
       vars:
         uan_sles15_packages_add:
           - foo
           - bar
         uan_sles15_packages_remove:
           - baz
         uan_sles15_repositories_add:
           - name: UAN SLE 15 SP3
             description: UAN SUSE Linux Enterprise 15 SP2 Packages
             url: https://packages.local/repository/uan-2.3.0-sle-15sp3
             priority: 2
```

This role is included in the UAN `site.yml` play.

License
-------

Copyright 2020-2021 Hewlett Packard Enterprise Development LP

Author Information
------------------

Hewlett Packard Enterprise Development LP

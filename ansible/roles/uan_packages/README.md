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

The `csm.gpg_keys` Ansible role must be installed if `uan_disable_gpg_check`
is false.

Role Variables
--------------

Available variables are listed below, along with default values (see defaults/main.yml):

```yaml
uan_disable_gpg_check: no
uan_sles15_repositories_add:[]
uan_sles15_packages_add:[]
uan_sles15_packages_remove:[]
```

This role uses the `zypper_repository` module. The `name`, `description`, `repo`,
`disable_gpg_check`, and `priority` fields are supported.

This role uses the `zypper` modules.  The `name` and `disable_gpg_check` fields are supported.

`uan_disable_gpg_check` sets the `disable_gpg_check` field on zypper repos and
packages listed in the `uan_sles15_repositories add` and `uan_sles15_packages_add`
lists.  The `disable_gpg_check` field can be overridden for each repo or package.

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
           - name: "foo"
             disable_gpg_check: yes
           - name: "bar"
         uan_sles15_packages_remove:
           - baz
         uan_sles15_repositories_add:
           - name: "uan-2.5.0-sle-15sp4"
             description: "UAN SUSE Linux Enterprise 15 SP4 Packages"
             repo: "https://packages.local/repository/uan-2.5.0-sle-15sp4"
             disable_gpg_check: no
             priority: 2
```

This role is included in the UAN `site.yml` play.

License
-------

MIT License

(C) Copyright [2020-2021] Hewlett Packard Enterprise Development LP

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

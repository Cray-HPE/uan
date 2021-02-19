uan_motd
=========

The `uan_motd` role appends text to the `/etc/motd` file.

Requirements
------------

None.

Role Variables
--------------

Available variables are listed below, along with default values (see defaults/main.yml):

```yaml
uan_motd_content: []
```

`uan_motd_content` contains text to be added to the end of the `/etc/motd` file.

Dependencies
------------

None.

Example Playbook
----------------

```yaml
- hosts: Application_UAN
  roles:
      - { role: uan_motd, uan_motd_content: "MOTD CONTENT" }
```

This role is included in the UAN `site.yml` play.

License
-------

Copyright 2019-2021 Hewlett Packard Enterprise Development LP

Author Information
------------------

Hewlett Packard Enterprise Development LP

uan_hardening
=========

The `uan_hardening` role configures site/customer-defined network security
 of UANs, for example preventing ssh out of UAN over NMN to NCN nodes.

Requirements
------------

None.

Role Variables
--------------

Available variables are listed below, along with default values (see
# defaults/main.yml):

### `disable_ssh_out_nmn_to_management_ncns`

`disable_ssh_out_nmn_to_management_ncns` is a boolean variable
 controlling whether or not firewall rules are applied at the UAN to
 prevent ssh outbound over the NMN to the NCN management nodes.


The default value of `disable_ssh_out_nmn_to_management_ncns` is `yes`.

```yaml
disable_ssh_out_nmn_to_management_ncns: yes
```

### `disable_ssh_out_uan_to_nmn_lb`

`disable_ssh_out_uan_to_nmn_lb` is a boolean variable
 controlling whether or not firewall rules are applied at the UAN to
 prevent ssh outbound over the NMN to NMN LB IPs.


The default value of `disable_ssh_out_uan_to_nmn_lb` is `yes`.

```yaml
disable_ssh_out_uan_to_nmn_lb: yes
```

Dependencies
------------

None.

Example Playbook
----------------

```yaml
- hosts: Application_UAN
  roles:
      - { role: uan_hardening}
```

This role is included in the UAN `site.yml` play.

License
-------

MIT License

(C) Copyright [2019-2022] Hewlett Packard Enterprise Development LP

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

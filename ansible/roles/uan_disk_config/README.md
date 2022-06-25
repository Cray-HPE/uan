uan_disk_config
=========

The `uan_disk_config` role configures swap and scratch disk partitions on UAN
nodes.

Requirements
------------

There must be disk devices found on the UAN node by the `device_filter` module
or this role will exit with failure. This condition can be ignored by setting
`uan_require_disk` to `false`. See variable definitions below.

See the `library/device_filter.py` file for more information on this module.

The device that is found will be unmounted if mounted and a swap partition will
be created on the first half of the disk, and a scratch partition on the second
half. ext4 filesystems are created on each partition.

Role Variables
--------------

Available variables are listed below, along with default values (see defaults/main.yml):

### `uan_require_disk`

Boolean to determine if this role continues to setup disk if no disks were found
by the device filter. Set to `true` to exit with error when no disks are found.

```yaml
uan_require_disk: false
```

### `uan_device_name_filter`

Regular expression of disk device name for this role to filter.
Input to the `device_filter` module.

```yaml
uan_device_name_filter: "^sd[a-f]$"
```

### `uan_device_host_filter`

Regular expression of host for this role to filter.
Input to the `device_filter` module.

```yaml
uan_device_host_filter: ""
```

### `uan_device_model_filter`

Regular expression of device model for this role to filter.
Input to the `device_filter` module.

```yaml
uan_device_model_filter: ""
```

### `uan_device_vendor_filter`

Regular expression of disk vendor for this role to filter.
Input to the `device_filter` module.

```yaml
uan_device_vendor_filter: ""
```

### `uan_device_size_filter`


Regular expression of disk size for this role to filter.
Input to the `device_filter` module.

```yaml
uan_device_size_filter: "<1TB"
```

### `uan_swap`

Filesystem location to mount the swap partition.

```yaml
uan_swap: "/swap"
```

### `uan_scratch`

Filesystem location to mount the scratch partition.

```yaml
uan_scratch: "/scratch"
```

### `swap_file`

Name of the swapfile to create. Full path is `<uan_swap>/<swapfile>`.

```yaml
swap_file: "swapfile"
```

### `swap_dd_command`

`dd` command to create the `swapfile`.

```yaml
swap_dd_command: "/usr/bin/dd if=/dev/zero of={{ uan_swap }}/{{ swap_file }} bs=1GB count=10"
```

### swap_swappiness

Value to set the swapiness in sysctl.

```yaml
swap_swappiness: 10
```

Dependencies
------------

`library/device_filter.py` is required to find eligible disk devices.

Example Playbook
----------------

```yaml
- hosts: Application_UAN
  roles:
      - { role: uan_disk_config }
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

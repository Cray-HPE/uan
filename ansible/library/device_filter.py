#!/usr/bin/env python3
#
# MIT License
#
# (C) Copyright 2020-2024 Hewlett Packard Enterprise Development LP
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
"""
The purpose of this ansible module is to allow filtering of devices
"""
import re

from ansible.module_utils.basic import AnsibleModule


ANSIBLE_METADATA = {
    'metadata_version': '2.5',
    'status': ['preview', 'stableinterface'],
    'supported_by': 'community'
}

DOCUMENTATION = """
---
module: device_filter

short_description: Filters devices from the "ansible_devices" fact

description:
    - Takes the data from "ansible_devices" and option filters
    - Returns only the devices that match the specified filters

options:
    device_data:
        required: True
        type: dict
    device_name_filter:
        required: False
        type: string
    device_name_exclude_filter:
        required: False
        type: string
    device_host_filter:
        required: False
        type: list
    device_host_exclude_filter:
        required: False
        type: list
    device_model_filter:
        required: False
        type: list
    device_model_exclude_filter:
        required: False
        type: list
    device_vendor_filter:
        required: False
        type: list
    device_vendor_exclude_filter:
        required: False
        type: list
    device_size_filter:
        required: False
        type: string
author:
    - rbak
    - keopp
"""


RETURN = """
devices:
    description: The devices matching the given filters
    type: dict
    returned: always
"""

UNITS_MAP = {
    'KB': 1000 ** 1,
    'MB': 1000 ** 2,
    'GB': 1000 ** 3,
    'TB': 1000 ** 4,
}


def run_module():
    module_args = dict(
        device_data=dict(type='dict', required=True),
        device_name_filter=dict(type='str', required=False, default=''),
        device_name_exclude_filter=dict(type='str', required=False, default=''),
        device_host_filter=dict(type='list', required=False, default=[]),
        device_host_exclude_filter=dict(type='list', required=False, default=[]),
        device_model_filter=dict(type='list', required=False, default=[]),
        device_model_exclude_filter=dict(type='list', required=False, default=[]),
        device_vendor_filter=dict(type='list', required=False, default=[]),
        device_vendor_exclude_filter=dict(type='list', required=False, default=[]),
        device_size_filter=dict(type='str', required=False, default=''),
    )
    result = dict(
        changed=False,
        devices={},
    )

    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True  # This module makes no changes
    )

    device_name_filter = module.params['device_name_filter']
    device_name_exclude_filter = module.params['device_name_exclude_filter']
    device_host_filter = module.params['device_host_filter']
    device_host_exclude_filter = module.params['device_host_exclude_filter']
    device_model_filter = module.params['device_model_filter']
    device_model_exclude_filter = module.params['device_model_exclude_filter']
    device_vendor_filter = module.params['device_vendor_filter']
    device_vendor_exclude_filter = module.params['device_vendor_exclude_filter']
    device_size_filter = module.params['device_size_filter']

    try:
        for key, device in module.params['device_data'].items():
            print(key, device)
            if device_name_filter and not re.match(device_name_filter, key):
                continue
            if device_name_exclude_filter and re.match(device_name_exclude_filter, key):
                continue
            if len(device_host_filter) and device.get('host', '') not in device_host_filter:
                continue
            if device.get('host', '') in device_host_exclude_filter:
                continue
            if len(device_model_filter) and device.get('model', '') not in device_model_filter:
                continue
            if device.get('model', '') in device_model_exclude_filter:
                continue
            if len(device_vendor_filter) and device.get('vendor', '') not in device_vendor_filter:
                continue
            if device.get('vendor', '') in device_vendor_exclude_filter:
                continue
            if device_size_filter and not compare_size(device_size_filter,
                                                       device.get('size', '00KB')):
                continue
            result['devices'][key] = device
        module.exit_json(**result)
    except Exception as e:
        module.fail_json(msg='Error while filtering device data: {}'.format(e), **result)


def compare_size(device_size_filter, size):
    size_filters = device_size_filter.split(',')
    for size_filter in size_filters:
        op = size_filter[0]
        filter_bytes = convert_to_bytes(size_filter[1:].strip())
        size_bytes = convert_to_bytes(size)
        if op == '>':
            if size_bytes < filter_bytes:
                return False
        elif op == '<':
            if size_bytes > filter_bytes:
                return False
        else:
            raise Exception('Invalid device_size_filter.  Must specify < or >')
    return True


def convert_to_bytes(size):
    units = size[-2:].upper()
    size = float(size[:-2].strip())
    if units not in UNITS_MAP:
        raise Exception('Invalid size units {}.  Must be {}'.format(
            units, ','.join(UNITS_MAP.keys())))
    return size * UNITS_MAP[units]


if __name__ == '__main__':
    run_module()

uan_metallb
=========

The `uan_metallb` role will deploy a list of HAProxy charts to a k3s cluster.

Each instance of HAProxy is to operate as an SSH load balancer to one or more
nodes.

Dependencies
------------

`uan_k3s_*` and `uan_helm` have run successfully. If MetalLB is to assign
Load Balancer IPs to services running in K3s, an IP address range must be
set in `vars/uan_helm.yml` or defined in SLS by divided the existing `[CAN|CHN]
Dynamic MetalLB` subnet in half creating a new `[CAN|CHN] Dynamic MetalLB K3s`
subnet:

Example of defining the MetalLB IP pool range in `vars/uan_helm.yml`:

```yaml
metallb_ipaddresspool_range_start: "<start-of-range>"
metallb_ipaddresspool_range_end: "<end-of-range>"
```

Here's an xample of splitting the existing `[CAN|CHN] Dynamic MetalLB` subnet. By default, the `FullName` of the subnet used for K3s is `[CAN|CHN] Dynamic MetalLB K3s`, depending on whether `CAN` or `CHN` is being used for the customer access network.  This default `FullName` of `[CAN|CHN] Dynamic MetalLB K3s` used by the role may be overridden by setting the `sls_can_metallb_fullname` variable in CFS to the expected name.

```bash
### Existing [CAN|CHN] Dynamic MetalLB Subnet in SLS
### Split this as shown below into two subnets
        "CIDR": "x.x.x.192/26",
        "FullName": "CAN Dynamic MetalLB",
        "Gateway": "x.x.x.193",
        "MetalLBPoolName": "customer-access",
        "Name": "can_metallb_address_pool",
        "VlanID": 6,

### New [CAN|CHN] Dynamic MetalLB Subnet
        "CIDR": "x.x.x.192/27",
        "FullName": "CAN Dynamic MetalLB",
        "Gateway": "x.x.x.193",
        "MetalLBPoolName": "customer-access",
        "Name": "can_metallb_address_pool",
        "VlanID": 6,

### New [CAN|CHN] Dynamic MetalLB K3s
        "CIDR": "x.x.x.224/27",
        "FullName": "CAN Dynamic MetalLB K3s",
        "Gateway": "x.x.x.225",
        "MetalLBPoolName": "customer-access-k3s",
        "Name": "can_metallb_k3s_address_pool",
        "VlanID": 6,
```

By default, these arguments are commented out or omitted. MetalLB will be
able to start, but the Custom Resource Definition for IPAddressPool and
L2AdvertisementAddress will not be created and no Load Balancer IP address
will be allocated.

Role Variables
--------------

Available variables are listed below, and are defined in vars/uan_helm.yml:

```yaml
metallb_chart: "metallb-0.13.7"
uan_metallb:
  name: "metallb"
  namespace: "metallb-system"
  chart: "{{ metallb_chart }}"
  chart_path: "{{ helm_install_path }}/charts/{{ metallb_chart }}.tgz"
#metallb_ipaddresspool_range_start: "<start-of-range>"
#metallb_ipaddresspool_range_end: "<end-of-range>"
```

Dependencies
------------

Configuration of `uan_k3s` and `uan_helm`

This role is included in the UAN `k3s.yml` play.

License
-------

MIT License

(C) Copyright [2023] Hewlett Packard Enterprise Development LP

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

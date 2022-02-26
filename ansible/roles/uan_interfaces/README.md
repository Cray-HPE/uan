uan_interfaces
=========

The `uan_interfaces` role configures site/customer-defined network interfaces
and Shasta Customer Access Network (CAN) network interfaces on UAN nodes.

Requirements
------------

None.

Role Variables
--------------

Available variables are listed below, along with default values (see defaults/
main.yml):

### `uan_can_setup`

`uan_can_setup` is a boolean variable controlling the configuration of user
access to UAN nodes.  When true, user access is configured over either the
Customer Access Network (CAN) or Customer High Speed Network (CHN), depending on which is configured on the system.

When `uan_can_setup` is false, user access over the CAN or CHN is not configured
on the UAN nodes and no default route is configured.  The Admin must then specify
the default route in `customer_uan_routes`.

The default value of `uan_can_setup` is `no`.

```yaml
uan_can_setup: no
```

### `uan_customer_default_route`

`uan_customer_default_route` is a boolean variable that allows the default route
to be set by the `customer_uan_routes` data when `uan_can_setup` is true.

By default, no default route is setup unless `uan_can_setup` is true, which sets the default route to the CAN or CHN.

```yaml
uan_customer_default_route: no
```

### `sls_nmn_name`

`sls_nmn_name` is the Node Management Network name used by SLS.
This value should not be changed.

```yaml
sls_nmn_name: "NMN"
```

### `sls_nmn_svcs_name`

`sls_nmn_svcs_name` is the Node Management Services Network name used by SLS.
This value should not be changed.

```yaml
sls_nmn_svcs_name: "NMNLB"
```

### `sls_mnmn_svcs_name`

`sls_mnmn_svcs_name` is the Mountain Node Management Services Network name used
by SLS.  This value should not be changed.

```yaml
sls_mnmn_svcs_name: "NMN_MTN"
```

### `uan_required_dns_options`

`uan_required_dns_options` is a list of DNS options.  By default, `single-request` is set and must not be removed.

```yaml
uan_required_dns_options:
  - 'single-request'
  ```

### `customer_uan_interfaces`

`customer_uan_interfaces` is as list of interface names used for constructing
`ifcfg-<customer_uan_interfaces.name>` files. Define ifcfg fields for each
interface here. Field names are converted to uppercase in the generated
`ifcfg-<name>` file(s).

Interfaces should be defined in order of dependency.

```yaml
customer_uan_interfaces: []

# Example:
customer_uan_interfaces:
  - name: "net1"
    settings:
      bootproto: "static"
      device: "net1"
      ipaddr: "1.2.3.4"
      startmode: "auto"
  - name: "net2"
    settings:
      bootproto: "static"
      device: "net2"
      ipaddr: "5.6.7.8"
      startmode: "auto"
```

### `customer_uan_routes

`customer_uan_routes` is as list of interface routes used for constructing
`ifroute-<customer_uan_routes.name>` files.

```yaml
customer_uan_routes: []

# Example
customer_uan_routes:
  - name: "net1"
    routes:
      - "10.92.100.0 10.252.0.1 255.255.255.0 -"
      - "10.100.0.0 10.252.0.1 255.255.128.0 -"
  - name: "net2"
    routes:
      - "default 10.103.8.20 255.255.255.255 - table 3"
      - "10.103.8.128/25 10.103.8.20 255.255.255.255 net2"
```

### `customer_uan_rules`

`customer_uan_rules` is as list of interface rules used for constructing
`ifrule-<customer_uan_routes.name>` files.

```yaml
customer_uan_rules: []

# Example
customer_uan_rules:
  - name: "net1"
    rules:
      - "from 10.1.0.0/16 lookup 1"
  - name: "net2"
    rules:
      - "from 10.103.8.0/24 lookup 3"
```

### `customer_uan_global_routes`

`customer_uan_global_routes` is a list of global routes used for constructing
the "routes" file.

```yaml
customer_uan_global_routes: []

# Example
customer_uan_global_routes:
  - routes: 
    - "10.92.100.0 10.252.0.1 255.255.255.0 -"
    - "10.100.0.0 10.252.0.1 255.255.128.0 -"
```

### `external_dns_searchlist`

`external_dns_searchlist` is a list of customer-configurable fields to be added
to the `/etc/resolv.conf` DNS search list.

```yaml
external_dns_searchlist: [ '' ] 

# Example
external_dns_searchlist:
  - 'my.domain.com'
  - 'my.other.domain.com'
```

### `external_dns_servers`

`external_dns_servers` is a list of customer-configurable fields to be added
to the `/etc/resolv.conf` DNS server list.

```yaml
external_dns_servers: [ '' ] 

# Example
external_dns_servers:
  - '1.2.3.4'
  - '5.6.7.8'
```

### `external_dns_options`

`external_dns_options` is a list of customer-configurable fields to be added
to the `/etc/resolv.conf` DNS options list.

```yaml
external_dns_options: [ '' ]

# Example
external_dns_options:
  - 'single-request'
```

### `uan_access_control`

`uan_access_control` is a boolean variable to control whether non-root access
control is enabled.  Default is `no`.

```yaml
uan_access_control: no
```

### `api_gateways`

`api_gateways` is a list of API gateway DNS names to block non-user access

```yaml
api_gateways:
  - "api-gw-service"
  - "api-gw-service.local"
  - "api-gw-service-nmn.local"
  - "kubeapi-vip"
```

### `api_gw_ports`

`api_gw_ports` is a list of gateway ports to protect.

```yaml
api_gw_ports: "80,443,8081,8888"
```

### `sls_url`

`sls_url` is the SLS URL.

```yaml
sls_url: "http://cray-sls"
```

Dependencies
------------

None.

Example Playbook
----------------

```yaml
- hosts: Application_UAN
  roles:
      - { role: uan_interfaces }
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

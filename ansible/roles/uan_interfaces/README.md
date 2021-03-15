uan_interfaces
=========

The `uan_interfaces` role configures site/customer-defined network interfaces
and Shasta Customer Access Network (CAN) network interfaces on UAN nodes.

Requirements
------------

None.

Role Variables
--------------

Available variables are listed below, along with default values (see defaults/main.yml):

### `uan_can_setup`

`uan_can_setup` configures the Customer Access Network (CAN) on UAN nodes. If
this value is falsey no CAN is configured on the nodes.

```yaml
uan_can_setup: no
```

### `sls_nmn_name`

`sls_nmn_name` is the Node Management Network name used by SLS.

```yaml
sls_nmn_name: "NMN"
```

### `sls_nmn_svcs_name`

`sls_nmn_svcs_name` is the Node Management Services Network name used by SLS.

```yaml
sls_nmn_svcs_name: "NMNLB"
```

### `sls_mnmn_svcs_name`

`sls_mnmn_svcs_name` is the Mountain Node Management Services Network name used by SLS.

```yaml
sls_mnmn_svcs_name: "NMN_MTN"
```

### `sls_can_name`

`sls_can_name` is the Customer Access Network name used by SLS.

```yaml
sls_can_name: "CAN"
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

Copyright 2019-2021 Hewlett Packard Enterprise Development LP

Author Information
------------------

Hewlett Packard Enterprise Development LP

uan_sshd
=========

The `uan_sshd` role will create and enable local instances of sshd.

Dependencies
------------

This role is intended to be paired with `uan_haproxy`, although it currently has
no explicit dependencies on that role other than they may be configure to operate
in tandem. See `uan_haproxy` for more information on pairing HAProxy with SSHD to
create SSH Load Balancers across on or more UANs.

Role Variables
--------------

Available variables are listed below, along with default values (see defaults/main.yml):

```yaml
uan_sshd_configs:
  - name: "uai"
    config_path: "/etc/ssh/uan"
    port: "9000"
    state: "started"
```

This will create the files `/etc/ssh/uan/sshd_uai_config` and 
`/usr/lib/systemd/system/sshd_uai.service` and set the systemd state based on the
`state` value.

The role will create the SSHD file based on the template defined in `templates/sshd_config.j2`.
Additional SSHD settings may be set using the following format:

```yaml
uan_sshd_configs:
  - name: "podman"
    port: "9001"
    config: |
      Match User *
        AcceptEnv DISPLAY
        X11Forwarding yes
        AllowTcpForwarding yes
        PermitTTY yes
        ForceCommand podman run -it --cgroup-manager=cgroupfs --userns=keep-id --network=host -e DISPLAY=$DISPLAY registry.local/cray/uai:1.0
```

Dependencies
------------

To pair this role with an instance of HAProxy, each HAProxy DaemonSet/Deployment running in K3s
must have a corresponding configuration in the HAProxy config. For example, in `vars/uan_helm.yml`:

```yaml
  - name: "haproxy-podman"
    namespace: "haproxy-podman"
    chart: "{{ haproxy_chart }}"
    chart_path: "{{ helm_install_path }}/charts/{{ haproxy_chart }}.tgz"
    args: "--set service.type=LoadBalancer"
    config: |
      global
        log stdout format raw local0
        maxconn 1024
      defaults
        log     global
        mode    tcp
        timeout connect 10s
        timeout client 36h
        timeout server 36h
        option  dontlognull
      listen ssh
        bind *:22
        balance leastconn
        mode tcp
        option tcp-check
        tcp-check expect rstring SSH-2.0-OpenSSH.*
        server host1 uan01:9001 check inter 10s fall 2 rise 1
        server host2 uan02:9001 check inter 10s fall 2 rise 1
        server host3 uan03:9001 check inter 10s fall 2 rise 1
```

When fully configured with K3s, HAProxy, and MetalLB, this will load balance connections to `haproxy-podman` to one
of the configured servers (host1, host2, or host3) based on the least connected host. Connections would be routed
to an SSHD running on port 9001, where that instance of SSHD could then force users into a podman container if
a `ForceCommand` option is configured appropriately.

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

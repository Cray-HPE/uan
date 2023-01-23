uan_haproxy
=========

The `uan_haproxy` role will deploy a list of HAProxy charts to a k3s cluster.

Each instance of HAProxy is to operate as an SSH load balancer to one or more
nodes.

Dependencies
------------

Helm, K3s, MetalLB, and corresponding SSHD servers must all be configured and running
for the full load balancer operating mode. See the README.mds for each component
(`uan_helm`, `uan_k3s_*`, `uan_metallb`, and `uan_sshd`) for more information.

Role Variables
--------------

Available variables are listed below, and are defined in vars/uan_helm.yml:

```yaml
third_party_url: "https://packages.local/repository/uan-2.6-third-party"
helm_path: "/usr/bin/helm"
helm_install_path: "/opt/cray/uan/helm"
haproxy_chart: "haproxy-1.17.3"

uan_haproxy:
  - name: "haproxy-uai"
    namespace: "haproxy-uai"
    chart: "{{ haproxy_chart }}"
    chart_path: "{{ helm_install_path }}/charts/{{ haproxy_chart }}.tgz"
```

By default, a single HAProxy instance will be deployed listening on port
22. If MetalLB has not been configured with a routeable IPAddressPool, the
HAProxy instance will only be reachable on the internal K3s network.

To check if MetalLB is configured with an IPAddressPool, check:
```bash
export KUBECONFIG=~/.kube/k3s.yml
kubectl describe IPAddressPool -A
...
Spec:
  Addresses:
    x.x.x.x-y.y.y.y (IP addresses removed)
...
```

To configure additional instances of HAProxy to operate in different modes,
configure the `config` key or add additional HAProxy instances to the list.
The `config` key will populate the jinja2 template in templates/haproxy-values.yml.j2
and will be used when deploying the HAProxy chart with helm. Individual 
arguments to the `helm install` command may also be defined by setting `args`.

```yaml
uan_haproxy:
  - name: "haproxy-uai"
    namespace: "haproxy-uai"
    chart: "{{ haproxy_chart }}"
    chart_path: "{{ helm_install_path }}/charts/{{ haproxy_chart }}.tgz"
    args: "--set service.type=LoadBalancer"
  - name: "haproxy-gpu"
    namespace: "haproxy-gpu"
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
```



Dependencies
------------

Configuration of `uan_k3s`, `uan_metallb`, `uan_helm`, and `uan_sshd`.

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

uan_k3s_stage
=========

The `uan_k3s_stage` role will download and stage k3s assets necessary to initialize
and configure k3s on a node.

Dependencies
------------

A configured location for the k3s assets. By default, this will be configured to use
a nexus repository installed by UAN on the Cray System Mangement Cluster. Some configuration
options are available to change where the assets are download from.

Role Variables
--------------

Available variables are listed below, and are defined in vars/uan_k3s.yml:

```yaml
third_party_url: "https://packages.local/repository/uan-2.6-third-party"
k3s_install_path: "/opt/k3s"
k3s_config_path: "/root/.kube"
k3s_config_file: "k3s.yml"
k3s_config: "{{ k3s_config_path }}/{{ k3s_config_file }}"
k3s_binary: "k3s"
k3s_install: "k3s-install.sh"
k3s_airgap: "k3s-airgap-images-amd64.tar"
k3s_airgap_env: "true"
k3s_install_env: "--disable servicelb --disable traefik --snapshotter fuse-overlayfs"

kubectl_path: "/usr/local/bin/kubectl"
kubectl_timeout: "60s"
```

Dependencies
------------

A location to download the k3s assets.

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

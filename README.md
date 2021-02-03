# User Access Nodes

This repository contains the following components for the Shasta User Access Nodes:

  1. Pre- and post-boot Ansible configuration (located in ansible/)
  2. UAN Image recipes (Kiwi-based) (located in images/)
  3. cray-uan-install Helm Chart (location in kubernetes/)
  4. Overall UAN version definition (see `vars.sh` file).

For packaging and installation scripts see the [uan-product-streams](https://stash.us.cray.com/projects/SCMS/repos/uan-product-stream/browse) repository.

For UAN RPM packages see the [uan-rpms](https://stash.us.cray.com/projects/SCMS/repos/uan-rpms/browse) repository.

## Updates Required for Release Management

* `vars.sh` - update the versions and locations of the UAN and its dependencies.
* `images/kiwi-ng/cray-sles15sp1-uan-cos/values-cje.yaml.j2` - update the repo names and locations
* `images/kiwi-ng/cray-sles15sp1-uan-cos/values-shasta.yaml.j2` - update the repo names and locations


#
# RPM spec file for uan ansible deployment
# Copyright 2018-2020 Hewlett Packard Enterprise Development LP
#
%define crayctl_dir /opt/cray/crayctl
%define ansible_dir %{crayctl_dir}/ansible_framework

Name: uan-crayctldeploy
License: HPE Proprietary
Summary: User Access Node ansible plays
Version: %(cat .rpm_version_uan-crayctldeploy)
Release: %(echo ${BUILD_METADATA})
Source: %{name}-%{version}.tar.bz2
Vendor: Hewlett Packard Enterprise Company

BuildRequires: cme-premium-cf-crayctldeploy-buildmacro

Requires: bos-crayctldeploy
Requires: cme-premium-cf-crayctldeploy
Requires: cray-crayctl
Requires: slurm-crayctldeploy
Requires: shasta-authorization-module

%description

%files
%dir %{crayctl_dir}
%{ansible_dir}
%{cme_premium_plays_dir}
%{cme_premium_roles_dir}
%{cme_premium_library_dir}

%prep
%setup -q

%build

%install
mkdir -p %{buildroot}%{crayctl_dir}
cp -R ansible %{buildroot}%{ansible_dir}

install -D -m 644 ansible/customer_runbooks/uan_config.yml %{buildroot}%{cme_premium_plays_dir}/uan_config.yml
mkdir -p %{buildroot}%{cme_premium_roles_dir}
mkdir -p %{buildroot}%{cme_premium_library_dir}
cp -R ansible/roles/uan_config %{buildroot}%{cme_premium_roles_dir}
cp -R ansible/roles/uan_interfaces %{buildroot}%{cme_premium_roles_dir}
cp -R ansible/roles/uan_ldap %{buildroot}%{cme_premium_roles_dir}
cp -R ansible/roles/uan_motd %{buildroot}%{cme_premium_roles_dir}
cp -R ansible/roles/uan_nologin %{buildroot}%{cme_premium_roles_dir}
install -D -m 644 ansible/library/device_filter.py %{buildroot}%{cme_premium_library_dir}/device_filter.py

%changelog
* Wed Oct 21 2020 0.2.17
- Fix location of device_filter.py so it gets to AEE
* Thu Oct 15 2020 0.2.16
- Fix customer_interfaces.yml to not read imported customer_var.yml
* Thu Oct 09 2020 0.2.15
- Support filterable disk selection during configuration
* Thu Oct 08 2020 0.2.14
- Support CAN over NMN NIC when bonded interface not available
* Tue Sep 22 2020 0.2.13
- Support additional fields in sssd.conf
* Wed Aug 12 2020 0.2.12
- Support bonded CAN interfaces
* Tue Aug 04 2020 0.2.11
- Increase timeout for BOS status endpoint to appear
* Mon Jul 27 2020 0.2.10
- Support LDAP and LDAPS
* Fri Jul 24 2020 0.2.9
- Update DVS rather than restart it
* Wed Jul 22 2020 0.2.8
- Add wait for BOS status endpoint to appear
* Wed Jul 15 2020 0.2.7
- Fix logic controlling use of BOS status endpoint
* Mon Jul 13 2020 0.2.6
- Only configure /etc/hosts if DNS is not available
* Thu Jul 09 2020 0.2.5
- Fix 1.3 branch to not pull master code
* Thu Jul 02 2020 0.2.4
- Get Application node xnames from SLS, if possible
* Wed Jul 01 2020 0.2.3
- Wait on new BOS status
* Thu Jun 18 2020 0.2.2
- Configure routing on eth0 for local services and mountain management
* Thu Jun 18 2020 0.2.1
- Configure /etc/nscd.conf to work with sssd
* Wed Jun 03 2020 0.1.52
- Add UAN tests
* Wed Jun 03 2020 0.1.51
- Support diskless UAN
* Tue Jun 02 2020 0.1.50
- Fix typo in customer_interfaces.yml
* Tue May 27 2020 0.1.49
- Add automatic selection for vlan007 interface
* Fri May 01 2020 0.1.48
- Add vlan007 route for virtual IPs
* Fri May 01 2020 0.1.47
- Update BOS session
* Tue Apr 21 2020 0.1.46
- Add uan_nologin to rpm
* Sat Apr 18 2020 0.1.45
- Restart cps
* Fri Apr 17 2020 0.1.44
- Don't umount filesystems if they are correct
* Fri Apr 17 2020 0.1.43
- Fix CAN interface default caused by udev changes
* Wed Apr 15 2020 0.1.42
- Add nologin support
* Tue Apr 14 2020 0.1.41
- Update uan_bos_base_template to 1.3.0
* Mon Apr 13 2020 0.1.40
- Allow arbitrary interfaces and routes to be configured
* Fri Apr 10 2020 0.1.39
- Make roles not run when cray_cfs_image
* Thu Apr 09 2020 0.1.38
- Fix uan_config umount
* Mon Apr 06 2020 0.1.37
- Add route from UAN to mountain NMN
* Fri Apr 03 2020 0.1.36
- Add forced umount if filesystem is mounted.
* Fri Apr 03 2020 0.1.35
- Scaling improvements.
* Fri Apr 03 2020 0.1.34
- Fix uan_ldap for CFS use.
* Mon Mar 30 2020 0.1.33
- Update uan_rootfs_provider to cpss3.
* Wed Mar 25 2020 0.1.32
- Check if filesystems are mounted and unmount them.
* Tue Mar 24 2020 0.1.31
- Link CAN to the proper interface
* Mon Mar 23 2020 0.1.30
- Remove check for CFS job name
* Fri Mar 13 2020 0.1.29
- Parameterize uan_motd release filename.
* Wed Mar 11 2020 0.1.28
- Harden ansible_hostname check in uan_interfaces.
* Mon Mar 09 2020 0.1.27
- Fix switchboard installation
* Mon Mar 09 2020 0.1.26
- Update cray-release to cle-release
* Sat Mar 07 2020 0.1.25
- Get can_version from imported_networks.
* Fri Feb 28 2020 0.1.24
- Sync the UAN BOS template construction to current BOS standards.
* Fri Feb 28 2020 0.1.23
- Force filesystem creation on UAN.
* Wed Feb 27 2020 0.1.22
- Harvest more UAN BOS session template variables from base template.
* Thu Feb 27 2020 0.1.21
- Add switchboard
* Wed Feb 26 2020 0.1.20
- Fix config of resolv.conf
* Fri Feb 21 2020 0.1.19
- Add CANv2 configuration
* Tue Feb 18 2020 0.1.18
- Fix auth issue during install.
* Fri Feb 14 2020 0.1.17
- Accept generic uan names and cabinets in xnames.
* Wed Feb 12 2020 0.1.16
- Conditionalize running uan.yml to only when UANs are defined.
* Mon Feb 10 2020 0.1.15
- Restart conman after UAN discovery.
* Thu Feb 06 2020 0.1.14
- Add check of CFS results.
* Sun Jan 19 2020 0.1.13
- Fix routing to local services broken by CAN.
* Mon Jan 13 2020 0.1.12
- Enable CAN on UAN
* Tue Jan 07 2020 0.1.11
- Remove setting hsn0
* Fri Jan 03 2020 0.1.10
- Fix WAR task names in uan_config role
* Wed Dec 18 2019 0.1.9
- Convert from CLI to authorized module
* Tue Dec 17 2019 0.1.4
- Fix parsing /etc/hosts for UAN xnames, clean up UAN /etc/hosts
* Tue Dec 17 2019 0.1.3
- Remove configuration roles from customer_runbooks, these are strictly CFS
* Thu Dec 12 2019 0.1.2
- Use BMC password from ansible vault
* Thu Nov 14 2019 0.1.1
- Fix parsing of /etc/hosts
* Fri Nov 08 2019 0.1.0
- Remove BOS partition from session template
* Fri Nov 08 2019 0.0.8
- Update product version default to 1.1.0
* Wed Oct 30 2019 0.0.7
- Use customer_var.yml for UAN customer networking definitions
* Thu Oct 24 2019 0.0.6
- Use BOS to boot UANs
* Thu Oct 03 2019 0.0.5
- Add shadow role
* Thu Aug 22 2019 0.0.4
- Add uan_bootstrap role
* Wed Aug 14 2019 0.0.3
- Remove slurm_node role from uan.yml
* Mon Aug 12 2019 0.0.2
- New versioning scheme
* Mon Jul 29 2019 0.0.1
- Initial uan-crayctldeploy

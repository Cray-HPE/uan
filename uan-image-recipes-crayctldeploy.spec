# Copyright 2019-2020 Hewlett Packard Enterprise Development LP

Name: cray-uan-image-recipes-crayctldeploy
License: Cray Software License Agreement
Summary: Cray deployment SLES15 uan image recipes
Group: System/Management
Version: %(cat .rpm_version_uan-images)
Release: %(echo ${BUILD_METADATA})
Source: %{name}-%{version}.tar.bz2
Vendor: Hewlett Packard Enterprise Development LP
Requires: cray-crayctl

# Project level defines TODO: These should be defined in a central location; DST-892
%define afd /opt/cray/crayctl/ansible_framework
%define roles %{afd}/roles
%define playbooks %{afd}/main
%define modules %{afd}/library

%description
KIWI-NG recipe(s) for creating the Cray SLES15 UAN image(s).

%prep
%setup -q

%build

%install
install -m 755 -d %{buildroot}/opt/cray/crayctl/image_recipes/
tar -cvzf %{buildroot}/opt/cray/crayctl/image_recipes/cray-sles15sp1-uan-%{version}.tgz -C images/kiwi-ng/cray-sles15sp1-uan-cos .
chmod 755 %{buildroot}/opt/cray/crayctl/image_recipes/cray-sles15sp1-uan-%{version}.tgz

%clean
rm -rf %{buildroot}/opt/cray/crayctl/image_recipes

%files
%defattr(755, root, root)
%dir /opt/cray/crayctl/image_recipes
/opt/cray/crayctl/image_recipes/cray-sles15sp1-uan-%{version}.tgz

%changelog

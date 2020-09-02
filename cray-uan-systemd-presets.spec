#
# spec file for package cray-uan-systemd-presets
#
# Copyright 2019-2020 Hewlett Packard Enterprise Development LP
#

################################################################################
# Primary package definition #
################################################################################
%define _presetdir /usr/lib/systemd/system-preset

Name:          cray-uan-systemd-presets
Vendor:        Hewlett Packard Enterprise Development LP
Version:       %(cat .rpm_version_uan-systemd-presets)
Release:       %(echo ${BUILD_METADATA})
Source:        %{name}.tar.bz2
BuildArch:     noarch
BuildRoot:     %{_tmppath}/%{name}-%{version}-%{release}
Group:         System/Management
License:       Cray Software License Agreement
Summary:       Enable/Disable Systemd services

%description
A collection of systemd services identified by Cray as those
that should be enabled or disabled to support Cray Shasta
system features.

%prep
%setup

%build

%install
%{__install} -m 0644 -D -t %{buildroot}%{_presetdir} systemd-presets/src/*.preset

%files
%defattr(-,root,root)
%{_presetdir}/*.preset

%pre

%post

%preun

%postun

%changelog

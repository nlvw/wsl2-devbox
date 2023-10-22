#!/usr/bin/env bash
#
# Container Build Distro Specific Setup
#

# Setup Bash Behavior
set -xeo pipefail

# Get OS Info
os_id="$(grep '^ID=' /etc/os-release | awk -F'=' '{print $2}' | sed 's/"//g')"
os_mver="$(grep '^VERSION_ID=' /etc/os-release | awk -F'=' '{print $2}' | sed 's/"//g' | awk -F'.' '{print $1}')"

# Update
dnf upgrade -y --refresh

# Fix Missing Manpages
if grep -q 'nodocs' /etc/dnf/dnf.conf; then
	cp "/etc/dnf/dnf.conf" "/etc/dnf/dnf.bak.conf"
	grep -v nodocs "/etc/dnf/dnf.bak.conf" > "/etc/dnf/dnf.conf"

	dnf remove -y man man-pages

	dnf install -y man man-pages

	dnf reinstall -y \*
fi

# Create Minimal System
dnf install -y --allowerasing \
	bind-utils \
	cracklib-dicts \
	curl \
	dnf-utils \
	file \
	findutils \
	glibc-common \
	glibc-langpack-en \
	glibc-locale-source \
	gzip \
	iproute \
	iputils \
	langpacks-en \
	ncurses \
	passwd \
	procps-ng \
	shadow-utils \
	sudo \
	systemd \
	systemd-udev \
	tar \
	util-linux \
	wget
dnf reinstall -y shadow-utils

# Setup Local
localedef -i en_US -f UTF-8 en_US.UTF-8
echo 'LANG="en_US.UTF-8"' > /etc/locale.conf

# Fix Ping
echo 'net.ipv4.ping_group_range=0 2000' > /etc/sysctl.d/50-ping.conf

# Fix Interop
rm -f /usr/lib/binfmt.d/mono.conf &>/dev/null || true
echo ":WSLInterop:M::MZ::/init:PF" > /usr/lib/binfmt.d/WSLInterop.conf

# Set Temp WSL Config
cat <<-EOF > /etc/wsl.conf
	[automount]
	enabled = true
	mountfstab = true
	root = /mnt/
	options = metadata,uid=1000,gid=1000,umask=0022,fmask=11,case=off

	[boot]
	systemd = true
	command = "/usr/sbin/sysctl --all -V >/tmp/sysctl.out 2> /tmp/sysctl.err"

	[interop]
	enabled = true
	appendwindowspath = true

	[network]
	generatehosts = true
	generateresolvconf = true
	hostname = devbox-${os_id}${os_mver}

	[user]
	default = root
EOF

# Cleanup
dnf clean all

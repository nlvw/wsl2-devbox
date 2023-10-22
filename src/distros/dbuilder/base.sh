#!/usr/bin/env bash
#
# Container Build Distro Specific Setup
#

# Setup Bash Behavior
set -xeo pipefail

# Create Minimal System
microdnf install -y \
	bash \
	findutils \
	gzip \
	podman \
	shadow-utils \
	tar \
	util-linux-core

# create user
groupadd -g 1000 dbuilder
useradd -g 1000 -u 1000 dbuilder
chown -R 1000:1000 /home/dbuilder

# Set Temp WSL Config
cat <<-EOF > /etc/wsl.conf
	[automount]
	enabled = true
	mountfstab = true
	root = /mnt/
	options = metadata,uid=1000,gid=1000,umask=0022,fmask=11,case=off

	[boot]
	command = "mount --make-rshared /"

	[interop]
	enabled = true
	appendwindowspath = true

	[network]
	generatehosts = true
	generateresolvconf = true
	hostname = dbuilder

	[user]
	default = dbuilder
EOF
chmod 644 /etc/wsl.conf

# Cleanup
microdnf clean all

# Fix File Caps For Podman
chmod 4755 /usr/bin/newgidmap
chmod 4755 /usr/bin/newuidmap
chmod u-s /usr/bin/new[gu]idmap
setcap cap_setuid+eip /usr/bin/newuidmap
setcap cap_setgid+eip /usr/bin/newgidmap

#!/usr/bin/env bash
#
# Post WSL Import Distro Specific Setup
#

# Setup Bash Behavior
set -xeo pipefail

# Update Existing Packages
dnf upgrade --refresh -y

# Install Dev Tools
dnf install -y \
	"@Development Tools" \
	"@RPM Development Tools" \
	acl \
	apptainer apptainer-suid \
	bash \
	bind-utils \
	bzip2 bzip3 \
	coreutils \
	curl \
	dbus dbus-x11 \
	diffutils colordiff \
	distrobox \
	dnf-plugin-system-upgrade \
	dos2unix \
	emacs-nox \
	fd-find \
	findutils \
	gawk \
	git git-all git-extras \
	glx-utils \
	gzip \
	iproute \
	make \
	mesa-dri-drivers \
	nano \
	ncurses \
	neofetch \
	neovim \
	net-tools \
	nmap-ncat \
	openssh-clients \
	podman podman-compose podman-docker buildah toolbox \
	procps-ng \
	python3 python3-devel python3-pip python3-wheel python3-setuptools \
	ranger \
	remove-retired-packages \
	ripgrep \
	rpmconf \
	rsync \
	screen \
	ShellCheck \
	symlinks \
	tar \
	telnet \
	tmux \
	tree \
	vim-enhanced \
	wget \
	xz \
	zip unzip

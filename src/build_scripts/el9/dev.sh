#!/usr/bin/env bash
#
# Container Build 
# EL9 Dev Environment
#

# Setup Bash Behavior
set -xeo pipefail

# Install Dev Tools
dnf install -y --allowerasing \
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
	neovim \
	net-tools \
	nmap-ncat \
	openssh-clients \
	podman podman-compose podman-docker buildah toolbox \
	procps-ng \
	python3 python3-devel python3-pip python3-wheel python3-setuptools \
	ranger \
	ripgrep \
	rsync \
	screen \
	ShellCheck \
	tar \
	telnet \
	tmux \
	tree \
	vim-enhanced \
	wget \
	xz \
	zip unzip

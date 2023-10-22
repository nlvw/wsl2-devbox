#!/usr/bin/env bash

# Setup Bash Behavior
set -xeo pipefail

# Get Args
user="$1"
hname="$2"

# create user
groupadd -g 1000 "$user"
useradd -g 1000 -u 1000 -m "$user"
echo "$user ALL=(ALL) NOPASSWD: ALL" > "/etc/sudoers.d/$user"
loginctl enable-linger 1000

# update wsl.conf
sed -i "s/hostname = .*/hostname = $hname/" /etc/wsl.conf
sed -i "s/default = root/default = $user/" /etc/wsl.conf

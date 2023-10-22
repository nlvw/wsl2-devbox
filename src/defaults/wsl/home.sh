#!/usr/bin/env bash

# Setup Bash Behavior
set -xeo pipefail

# Set Umask
umask 0027

# Copy Home Files
/bin/cp -Rf ./src/defaults/home/. "$HOME"

# Adjust Permissions
sudo chown -R "$USER":"$USER" "$HOME"
chmod -R 'u=rwX,g=rX,o=' "$HOME"

# Symlink .ssh directory
ln -sf "/mnt/c/Users/$USER/.ssh" "$HOME/.ssh"

# Ensure Authorized Keys File
if [ ! -f "$HOME/.ssh/authorized_keys" ]; then
	touch "$HOME/.ssh/authorized_keys"
fi

# Ensure SSH Config File
if [ ! -f "$HOME/.ssh/config" ]; then
	/bin/cp -f ./src/defaults/ssh/config "$HOME/.ssh/config"
fi

# Ensure SSH known hosts file
if [ ! -f "$HOME/.ssh/known_hosts" ]; then
	touch "$HOME/.ssh/known_hosts"
fi

# Ensure Default SSH Key Exists
if [ ! -f "$HOME/.ssh/id_ed25519" ] || [ ! -f "$HOME/.ssh/id_ed25519.pub" ]; then
	echo ""
	echo ""
	echo "Default SSH Key Missing! Creating!! User Input Required!!!"
	read -rp "Key Comment (No Spaces): " comment
	ssh-keygen -t ed25519 -a 100 -C "$comment" -f "$HOME/.ssh/id_ed25519"
fi

# Ensure Correct Permissions on .ssh and subfiles
chmod 700 "$HOME/.ssh"
chmod 600 "$HOME/.ssh"/*

# Ensure GPG Directory Permissions
mkdir -p "$HOME/.gnupg"
chmod 700 "$HOME/.gnupg"
chmod 600 "$HOME/.gnupg"/*

# Enable SSH Agent
systemctl --user daemon-reload
systemctl --user enable --now ssh-agent.service

# Enable GPG Agent Socket
systemctl --user enable --now gpg-agent.socket

# Enable Podman Socket
systemctl --user enable --now podman.socket

# Install zellij
chmod +x "$HOME/.local/bin/zellij-update"
#"$HOME/.local/bin/zellij-update"

# Install Helix
chmod +x "$HOME/.local/bin/helix-update"
#"$HOME/.local/bin/helix-update"

#!/usr/bin/env bash

# Ensure .bashrc was sourced
if [ -f ~/.bashrc ]; then
	source ~/.bashrc
fi

# Set Umask
umask 0027

# Correct trailing slash in XDG Run
XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR%/}"
export XDG_RUNTIME_DIR

# Attempt To Fix DBUS WSL Issue
if [ ! -f "$XDG_RUNTIME_DIR/dbus" ]; then
	sudo systemctl restart "user@$UID"
fi

# Setup Local Bin
if [ ! -d "$HOME/.local/bin" ]; then
	mkdir -p "$HOME/.local/bin"
fi
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
	PATH="$HOME/.local/bin:${PATH}"
fi

# Setup Cache Folder
XDG_CACHE_HOME="$HOME/.cache"
export XDG_CACHE_HOME
if [ ! -d "$XDG_CACHE_HOME" ]; then
	mkdir "$XDG_CACHE_HOME"
fi

# SSH Env For Agent (Systemd Will Start Agent)
SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
export SSH_AUTH_SOCK

# GPG Agent ENV For Pinentry
GPG_TTY=$(tty)
export GPG_TTY

# Setup Git Bash Completions
if [ -f "/usr/share/bash-completion/completions/git" ]; then
	source /usr/share/bash-completion/completions/git
fi

# Setup Zellij Bash Completion
if command -v zellij &>/dev/null; then
	eval "$(zellij setup --generate-completion bash)"
fi

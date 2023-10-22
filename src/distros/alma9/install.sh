#!/usr/bin/env bash
#
# Post WSL Import Distro Specific Setup
#

# Setup Bash Behavior
set -xeo pipefail

# Update Existing Packages
dnf upgrade --refresh -y

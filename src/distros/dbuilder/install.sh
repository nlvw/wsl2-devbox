#!/usr/bin/env bash
#
# Post WSL Import Distro Specific Setup
#

# Setup Bash Behavior
set -xeo pipefail

# Fix File Caps For Podman
chmod 4755 /usr/bin/newgidmap
chmod 4755 /usr/bin/newuidmap
chmod u-s /usr/bin/new[gu]idmap
setcap cap_setuid+eip /usr/bin/newuidmap
setcap cap_setgid+eip /usr/bin/newgidmap

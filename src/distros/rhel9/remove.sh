#!/usr/bin/env bash
#
# Pre WSL Unregister Distro Specific Cleanup
#

# Setup Bash Behavior
set -xeo pipefail

# Unregister With RHEL Satellite
subscription-manager unregister

#!/usr/bin/env bash
#
# Container Build
# Nvidia GPU Support
#

# Setup Bash Behavior
set -xeo pipefail

# Install Cuda Software (Not The Driver!!)
if [ "$1" == "true" ]; then
	curl -o /etc/yum.repos.d/cuda-rhel8.repo https://developer.download.nvidia.com/compute/cuda/repos/rhel8/x86_64/cuda-rhel8.repo
	dnf install -y cuda-toolkit
fi

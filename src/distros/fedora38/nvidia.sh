#!/usr/bin/env bash
#
# Container Build
# Nvidia GPU Support
#

# Setup Bash Behavior
set -xeo pipefail

# Install Cuda Software (Not The Driver!!)
if [ "$1" == "true" ]; then
	echo "NVIDIA does not yet support Fedora 38! Skipping!!"
	# curl -o /etc/yum.repos.d/cuda-fedora.repo https://developer.download.nvidia.com/compute/cuda/repos/fedora38/x86_64/cuda-fedora38.repo
	# dnf install -y cuda-toolkit
fi

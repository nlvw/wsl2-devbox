#!/usr/bin/env bash

image_url="https://cloud-images.ubuntu.com/wsl/jammy/current/ubuntu-jammy-wsl-amd64-wsl.rootfs.tar.gz"

podman import "$image_url" local-url-rootfs
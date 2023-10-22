#!/usr/bin/env bash

# Setup Bash Behavior
set -xeo pipefail

# Set Directory Variables
Script_Dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
Distro_Dir="$Script_Dir/$1"
SRC_DIR="$(dirname "$Script_Dir")"
TARS_DIR="$(dirname "$SRC_DIR")/tarballs"

# Setup Temp Directory
TMP_DIR="$(mktemp -d)"

# Determine If Nvidia GPU
if [ -f '/usr/lib/wsl/lib/libcuda.so' ]; then
	NVIDIA="true"
else
	NVIDIA="false"
fi

# Ensure Working Directory
cd "$SRC_DIR"

# Get List Of Distros
distros="$(find "$Script_Dir" -mindepth 1 -maxdepth 1 -type d | sed "s|$Script_Dir/||")"

# Build and Export Image
distro="$1"
if echo "$distros" | grep -q "^${distro}$"; then
	name="wsl2-$distro"
	tag="$name:latest"

	# Import Image From Url
	if [ -f "$Distro_Dir/image.sh" ]; then
		bash "$Distro_Dir/image.sh"
	fi

	# Build Container
	podman build -t "$tag" --build-arg="NVIDIA=$NVIDIA" -f "$Distro_Dir/Dockerfile" .

	# Initiate and Export Container
	podman run --name "$name" -t "$tag" echo "Hello World!"
	podman export --output "$TMP_DIR/$distro.tar" "$name"
	podman rm "$name"

	# Compress and Move Exported Container
	gzip -f -9 "$TMP_DIR/$distro.tar"
	if [ -f "$TARS_DIR/$distro.tar.gz" ]; then
		rm -f "$TARS_DIR/$distro.tar.gz"
	fi
	mv -f "$TMP_DIR/$distro.tar.gz" "$TARS_DIR/$distro.tar.gz"

	# Cleanup Built Container
	podman rmi "$tag"

else
	echo "'$1' is not a valid distro. Stopping."
	exit 54
fi

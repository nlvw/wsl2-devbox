#!/usr/bin/env bash
#
# Post WSL Import Distro Specific Setup
#

# Setup Bash Behavior
set -xeo pipefail

# Get Directories
script_dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
build_scripts="$(dirname "$(dirname "$script_dir")")/build_scripts/el8"

# Register with Subscription Manager
PS3="Select Subscription Manager Registration Method: "
select opt in cloud-user cloud-key satellite ; do
	case $opt in
		cloud-user)
			read -rp "Username: " username
			read -rsp "Password: " password
			subscription-manager register --username "$username" --password "$password"
			break
			;;
		cloud-key)
			read -rp "Org Name: " org
			read -rp "Activation Key: " akey
			subscrution-manager register --org "$org" --activationkey "$akey"
			break
			;;
		satellite)
			echo "Generate a registeration curl command from your satellite instance!"
			echo "If using a self-signed cert you may need to select the insecure option!!"
			echo
			read -rp "Curl Command: " curl_cmd
			$curl_cmd
			break
			;;
		*)
			echo "Invalid Option '$REPLY'"
			;;
	esac
done

# Update Existing Packages
dnf upgrade --refresh -y

# Setup Insights Client
dnf install -y insights-client
insights-client --register

# Install Dev Tools
bash "$build_scripts/dev.sh"

# Install Cuda Software (Not The Driver!!)
if [ -f '/usr/lib/wsl/lib/libcuda.so' ]; then
	bash "$build_scripts/nvidia.sh" "true"
fi

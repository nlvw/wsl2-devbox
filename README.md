# WSL2 Dev Environment Setup

This repo contains scripts that will setup a somewhat opinionated Linux dev environment on a Windows 11 workstation using Windows Subsystem for Linux.  Current support is focused on RHEL/EL/Fedora Linux Distros. Some genaric, but opinionated, defaults are included but feel free to fork to tailor to your specific needs.

The project automates the building of reusable Linux Distro tarballs optimized for WSL and the current system. It will then use those tarball to install named WSL distros with varying levels of integration with Windows (SSH, GPU, etc..).  Everything is self contained within this cloned repository to make it easy to track disk usage.

- [WSL2 Dev Environment Setup](#wsl2-dev-environment-setup)
  - [Requirements](#requirements)
    - [Optional Reccomendations](#optional-reccomendations)
  - [Setup](#setup)
  - [Features](#features)
    - [Windows](#windows)
    - [Linux](#linux)
  - [Remote Access](#remote-access)
  - [Distro Version Upgrades](#distro-version-upgrades)
    - [Fedora](#fedora)
    - [Others](#others)
  - [To Do](#to-do)

## Requirements

- Git Client
- Windows 11 Pro/Education/Enterprise
- Admin Rights

### Optional Reccomendations

- Windows 11 23H2 or newer
  - Required for some of the defaults used for ~/.wslconfig (network mirror mode, firewall, auto proxy, and more)
  - As of 22Oct2023 requires any insider preview (Tested Build 22631.2428)
- WSL Version 2.0.5.0
  - After initial setup run `wsl --update --pre-release --web-download` from an admin powershell prompt
  - As of 22Oct2023 requires any insider preview (Tested Build 22631.2428)
- Bitlocker Encryption
  - Ensure your boot disk, any user profile disk, and the location your putting this repo are all encrypted.
  - Backup your bitlocker recoverkeys to a safe place in-case of failed TPM, bios/firmware updated not properly handled, or any other reason that would require said key.
  - Part of the setup enables the windows ssh-agent so unless you disable this encryption of your hard drive is highly reccommended.

## Setup

- Install Git.
  - Admin Powershell Run `winget install --id Git.Git --exact --disable-interactivity --accept-source-agreements --silent --force`
- Clone This Repository in the desired directory to store your WSL distros.
  - Powershell Run `git clone https://github.com/nlvw/wsl2-devbox.git`
- Run Setup Scripts
  - From the 'wsl_linux_devbox' directory, do the following from an Admin Powershell prompt:
    - 1\. `Set-ExecutionPolicy RemoteSigned -Force`
    - 2\. `.\src\setup-1.ps1`
    - 3\. Reboot Computer
    - 4\. `.\src\setup-2.ps1`
    - 5\. Update to pre-release of wsl if needed
      - `wsl --update --pre-release --web-download`
- Install Desired WSL Distro
  - Powershell Run `.\distro-install.ps1 -Name {name} -Distro {distro} -Default {$true/$false}`
    - Use tab completion with `-Distro`, and other flags, to see the list of options.
    - `-Name` is what you want the hostname of the linux distro to be.
    - `-Distro` is what linux distro you want to base on (limited list available).
    - `-Default` is wether you want the new distro to be the default one used by wsl when `-d` is not provided.
    - `-ReBuild` will rebuild the distro tarball even if you have built it previously.

## Features

### Windows

- Common Dev Tools
  - 3rd party tools are installed via Winget.
- Hyper-V
  - Additional Support for other hypervisors on Hyper-V
- Windows Subsystem for Linux (WSL)
- OpenSSH Client
  - The '~/.ssh' directory is shared between Windows and Linux
  - A default SSH key is created ('~/.ssh/id_ed25519') and the user is prompted for a password. Setting a password is highly recommended.
  - A default config file is provided ('~/.ssh/config').

### Linux

- Systemd is enabled (not the default for WSL2)
- Nested Virtualization is Enabled
- Ports in WSL are automatically forwarded to the same port in Windows and accessible via localhost.
- Experimental features such as network mirroring, firewall enforcement, auto proxy, and others are enabled by default.
- SSH Client + Agent
  - All details of the Windows OpenSSH client here as well.
  - A single 'ssh-agent' is started automatically and controlled by systemd (`systemctl --user status ssh-agent.service`).
  - Keys are set to timeout and be removed after 9 hours.
- GPG Agent
  - A single 'gpg-agent' is started automatically and controlled by systemd (`systemctl --user status gpg-agent.socket`).
  - Keys are set to timeout and be removed after 9 hours.
- Common Dev Tools
  - Terminal Editors
  - Terminal Multiplexors
  - Container Runtimes and Libraries
    - Podman
      - Docker socket support is enabled automatically (`systemctl --user status podman.socket`).
      - Docker compose support is enabled.
    - Apptainer
    - Toolbox (If included in distros repos)
    - Distrobox
  - Default configs for bash and a few other tools is included.

## Remote Access

For remote access the easiest, and only documented method here, is to RDP into your windows machine then use the Windows Terminal to use WSL.

## Distro Version Upgrades

### Fedora

Update no more then 2 major release versions at a time (36 -> 38 or 37 -> 38).  Be wary of nvidia or other 3rd party repos as they will likely require manual udpates. Nvidia especially lags behind on supporting new versions of Fedora.

```bash
sudo dnf upgrade --refresh -y
sudo dnf system-upgrade download --releasever=38
export DNF_SYSTEM_UPGRADE_NO_REBOOT=1
sudo -E dnf system-upgrade reboot
sudo -E dnf system-upgrade upgrade
sudo dnf upgrade --refresh -y
```

```powershell
wsl.exe --shutdown
```

https://docs.fedoraproject.org/en-US/quick-docs/dnf-system-upgrade/#sect-optional-post-upgrade-tasks

```bash
rpmconf -a -u use_maintainer
sudo remove-retired-packages 37
sudo dnf repoquery --unsatisfied
sudo dnf repoquery --duplicates
sudo dnf list extras
#sudo dnf remove $(sudo dnf repoquery --extras --exclude=kernel,kernel-\*)
sudo dnf autoremove -y
sudo symlinks -r /usr | grep dangling
sudo symlinks -r -d /usr
```

### Others

Major version upgrades are difficult at best (even worse then the fedora process described above.).  Your best bet is to do a git pull on this repository to get any updated distros, install the new one, then transfer any files you need before removing the old one.

## To Do

- Verify RHEL distros work.
  - Test and fix all 3 subscription manager methods.
- GPU Acceleration
  - Implement NVIDIA GPU Support
    - Fedora 38 has no NVIDIA repo for cuda
    - Ubuntu/Debian not implemented
    - For the rest cuda is installed and works but 3d acceleration needs testing.
  - Implement Intel GPU Support (Integrated/Dedicated)
  - Implement AMD GPU Support (Integrated/Dedicated)
  - Explore multi-gpu scenarios and/or selection.
- Add Latest Ubuntu LTS Linux
  - There's some placeholders but nothing working yet.
- Add Latest Debian Linux
- Add NixOS Linux
- Add Arch Linux
- Document Remote access using the new network/firewall/proxy mirroring.
- Document Windows VPN usage using the new network mirroring.
  - Works but as of 2.0.5 routing gets messed up so you need to shutdown wsl and start it again then it works fine for the duration of the connection.
#Requires -Version 5.1

param (
	[Parameter(Mandatory=$true)]
	[ValidateScript({
		$installed = (wsl.exe -l -q).split("\n")
		if ($installed -contains $_) {
			throw "'$_' is the name of a already installed distro."
		}
		elseif ($_ -contains " " ) {
			throw "'$_' contains a space. No spaces allowed."
		}
		else {
			$true
		}
	})]
	[String]$Name,
	
	[Parameter(Mandatory=$true)]
	[ValidateSet(
		"alma8",
		"alma9",
		"centos8",
		"centos9",
		"dbuilder",
		"fedora37",
		"fedora38",
		"fedora40",
		"oracle8",
		"oracle9",
		"rhel8",
		"rhel9",
		"rocky8",
		"rocky9"
	)]
	[String]$Distro,
	
	[ValidateSet("true", "false")][string]$Default = "false",
	[ValidateSet("true", "false")][string]$ReBuild = "false"
)

# Set Error Action
$ErrorActionPreference = "Stop"

# Ensure Not Running As Admin
if (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
	Write-Host -ForegroundColor Red "Don't Run This Script From Admin Powershell!"
	exit 22
}

# Set Working Directory
Set-Location "$PSScriptRoot"

# Ensure .wslconfig
if (!(Test-Path "$env:USERPROFILE/.wslconfig")) {
	Copy-Item -Path "$PSScriptRoot/src/defaults/wsl/.wslconfig" -Destination "$env:USERPROFILE/.wslconfig" -Force 1>$null
}

# Setup Exe Call Function
function Invoke-Call {
	param (
		[scriptblock]$ScriptBlock,
		[string]$ErrorAction = $ErrorActionPreference
	)
	& @ScriptBlock
	if (($lastexitcode -ne 0) -and $ErrorAction -eq "Stop") {
		exit $lastexitcode
	}
}

# Handle Distro Tarball
$tarball = "$PSScriptRoot\tarballs\$Distro.tar.gz"
if ((!(Test-Path "$tarball")) -or ([System.Convert]::ToBoolean($ReBuild))) {
	# Get installed wsl distros
	$installed = (wsl.exe -l -q).split("\n")

	# Install dbuilder distro
	if (($Distro -contains "dbuilder") -and (!($installed -contains "dbuilder"))) {
		Invoke-WebRequest "https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-Container-Minimal.latest.x86_64.tar.xz" -OutFile "$PSScriptRoot\tarballs\bootstrap.tar.gz"
		Invoke-Call -ScriptBlock { wsl --import "$Name" "$PSScriptRoot/distros/$Name" "$PSScriptRoot\tarballs\bootstrap.tar.gz" }
		Invoke-Call -ScriptBlock { wsl -d "$Name" -u root -e /bin/bash ./src/distros/$Distro/base.sh }
		Invoke-Call -ScriptBlock { wsl --terminate "$Name" }
		Remove-Item -Path "$PSScriptRoot\tarballs\bootstrap.tar.gz" -Force
		$ReBuild="true"
	}
	elseif (!($installed -contains "dbuilder")) {
		Invoke-Expression -Command ($PSCommandPath + ' -Name dbuilder -Distro dbuilder')
	}
	else {
		# dbuilder wsl distro already installed nothing to do
	}

	# Build/Rebuild tarball
	Invoke-Call -ScriptBlock { wsl -d "dbuilder" -u dbuilder -e /bin/bash ./src/distros/build.sh "$Distro" "$ReBuild" }
	
	# Remove dbuilder distro
	Invoke-Expression -Command ("$PSScriptRoot\distro-remove.ps1" + ' -Name dbuilder')
}

# Import Tarball
Invoke-Call -ScriptBlock { wsl --import "$Name" "$PSScriptRoot/distros/$Name" "$tarball" }

# Set Default
if ([System.Convert]::ToBoolean($Default)) {
	Invoke-Call -ScriptBlock { wsl --set-default "$Name" }
}

# Run Distro Install Script
Invoke-Call -ScriptBlock { wsl -d "$Name" -u root -e /bin/bash ./src/distros/$Distro/install.sh }

# User Setup (non dbuilder distros)
if (!($Distro -contains "dbuilder")) {
	# Stop To Pickup Potential changes in /etc/wsl.conf from install.sh
	Invoke-Call -ScriptBlock { wsl --terminate "$Name" }

	# Create User
	Invoke-Call -ScriptBlock { wsl -d "$Name" -u root -e /bin/bash ./src/defaults/wsl/user.sh "$env:USERNAME" "$Name" }
	
	# Stop To Pickup Default User Changes in /etc/wsl.conf
	# Full WSL shutdown to solve conflicts with user dbus when multiple wsl distros are running (everything after the first has a broken dbus)
	Invoke-Call -ScriptBlock { wsl --shutdown}

	# Setup User Home Directory
	Invoke-Call -ScriptBlock { wsl -d "$Name" -e /bin/bash ./src/defaults/wsl/home.sh }
}

# Shutdown To Ensure Clean User Startup
Invoke-Call -ScriptBlock { wsl --terminate "$Name" }

# Copy Remove Script
if (Test-Path "$PSScriptRoot\src\distros\$Distro\remove.sh") {
	Copy-Item -Path "$PSScriptRoot\src\distros\$Distro\remove.sh" -Destination "$PSScriptRoot\distros\$Name\remove.sh" -Force
}

# Report Done
Write-Host -ForegroundColor Green "All Done! Enjoy!!"

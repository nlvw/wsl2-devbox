#Requires -RunAsAdministrator
#Requires -Version 5.1

# Set Error Action
$ErrorActionPreference = "Stop"

# Validate Windows 11
if (!((Get-ComputerInfo | Select-Object -expand OsName) -match 11)) {
	write-host -ForegroundColor Red "Windows 11 is Required!"
	exit 11
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

# Function to Install Features
function Install-CustomFeature {

	param (
		$Features = (Get-WindowsOptionalFeature -Online),
		[Parameter(Mandatory=$true)][String]$Name
	)

	# Get Feature Install Status
	$state = ($Features | Where-Object -Property FeatureName -EQ $Name).State

	# Install Feature if Missing
	if ($state -ne "Enabled") {
		Write-Host -ForegroundColor Green "Installing '$Name'!"
		Enable-WindowsOptionalFeature -Online -FeatureName "$Name" -All -NoRestart -ErrorAction Stop
		Write-Host -ForegroundColor Yellow "Restart is Required!!"
	}

}

# Function to Install Capabilities
function Install-CustomCapability {

	param (
		$Capabilities = (Get-WindowsCapability -Online),
		[Parameter(Mandatory=$true)][String]$Name
	)

	# Get Feature Install Status
	$state = ($Capabilities | Where-Object -Property Name -EQ $Name).State

	# Install Feature if Missing
	if ($state -ne "Installed") {
		Write-Host -ForegroundColor Green "Installing '$Name'!"
		Add-WindowsCapability -Online -Name "$Name" -ErrorAction Stop
	}

}

# Get List and Status of Features
$features = Get-WindowsOptionalFeature -Online

# Install Hyper-V
Install-CustomFeature -Features $features -Name 'Microsoft-Hyper-V-All'

# Install Virtual Machine Platform
Install-CustomFeature -Features $features -Name 'VirtualMachinePlatform'

# Install Windows Hypervisor Platform
Install-CustomFeature -Features $features -Name 'HypervisorPlatform'

# Install WSL
Install-CustomFeature -Features $features -Name 'Microsoft-Windows-Subsystem-Linux'

# Get List and Status of Capabilities
$capabilities = Get-WindowsCapability -Online

# Install OpenSSH Client
Install-CustomCapability -Capabilities $capabilities -Name 'OpenSSH.Client~~~~0.0.1.0'

# Set Powershell Execution Policy
if ((Get-ExecutionPolicy) -ne "RemoteSigned") {
	Write-Host -ForegroundColor Green "Setting PS Execution Policy to RemoteSigned!"
	Set-ExecutionPolicy RemoteSigned
}

# Install or Upgrade Dev Tools
winget install --id 7zip.7zip --exact --disable-interactivity --accept-source-agreements --silent --force
winget install --id Git.Git --exact --disable-interactivity --accept-source-agreements --silent --force
winget install --id Microsoft.PowerToys --exact --disable-interactivity --accept-source-agreements --silent --force
winget install --id Microsoft.Teams --exact --disable-interactivity --accept-source-agreements --silent --force
winget install --id Microsoft.VisualStudioCode --exact --disable-interactivity --accept-source-agreements --silent --force
winget install --id Microsoft.WindowsTerminal --exact --disable-interactivity --accept-source-agreements --silent --force
winget install --id mRemoteNG.mRemoteNG --exact --disable-interactivity --accept-source-agreements --silent --force
winget install --id Notepad++.Notepad++ --exact --disable-interactivity --accept-source-agreements --silent --force
winget install --id PuTTY.PuTTY --exact --disable-interactivity --accept-source-agreements --silent --force
winget install --id WinSCP.WinSCP --exact --disable-interactivity --accept-source-agreements --silent --force

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

# Setup SSH Agent
Set-Service -Name 'ssh-agent' -StartupType Automatic
Start-Service -Name 'ssh-agent'

# Ensure .ssh folder
if (!(Test-Path "$env:USERPROFILE\.ssh")) {
	New-Item -Path "$env:USERPROFILE\.ssh" -ItemType Directory
	Invoke-Call -ScriptBlock { icacls "$env:USERPROFILE\.ssh" /c /Inheritance:d }
	Invoke-Call -ScriptBlock { icacls "$env:USERPROFILE\.ssh" /c /Grant "${env:UserName}:(OI)(CI)(F)" }
	Invoke-Call -ScriptBlock { icacls "$env:USERPROFILE\.ssh" /c /Remove:g "Authenticated Users" BUILTIN Everyone Users }
}

# config git to use openssh
Invoke-Call -ScriptBlock { git config --global core.sshCommand "'C:\Windows\System32\OpenSSH\ssh.exe'" }

# Update WSL
Write-Host -ForegroundColor Green "Updating WSL!"
Invoke-Call -ScriptBlock { wsl --update }
Invoke-Call -ScriptBlock { wsl --shutdown }
Invoke-Call -ScriptBlock { wsl --version }

# Set Default WSL Version
Write-Host -ForegroundColor Green "Setting Default WSL to v2!"
Invoke-Call -ScriptBlock { wsl --set-default-version 2 }

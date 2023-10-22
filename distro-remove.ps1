#Requires -Version 5.1

param (
	[Parameter(Mandatory=$true)]
	[ValidateScript({
		$installed = (wsl.exe -l -q).split("\n")
		if (!($installed -contains $_)) {
			throw "'$_' is not the name of an installed distro."
		}
		elseif (!(Test-Path "$PSScriptRoot\distros\$_")) {
			throw "'$_' is not a distro managed by this repository."
		}
		else {
			$true
		}
	})]
	[String]$Name
)

# Set Error Action
$ErrorActionPreference = "Stop"

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

# Set Working Directory
Set-Location "$PSScriptRoot"

# Run Remove Shell Script
if (Test-Path "$PSScriptRoot\distros\$Name\remove.sh") {
	Invoke-Call -ScriptBlock { wsl -d "$Name" -u root -e /bin/bash ./distros/$Name/remove.sh }
}

# Uninstall WSL Distro
Invoke-Call -ScriptBlock { wsl --unregister "$Name" }

# Cleanup Folder
Remove-Item -Path "$PSScriptRoot\distros\$Name" -Recurse -Force

# Report Done
Write-Host -ForegroundColor Green "Removal/Uninstall of distro '$Name' was successful!"

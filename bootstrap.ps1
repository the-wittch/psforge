[CmdletBinding()]
param(
    [Parameter()]
    [switch]$Install,

    [Parameter()]
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
$RepoRoot = $PSScriptRoot
$SourceModule = Join-Path -Path $RepoRoot -ChildPath 'src/PSForge'
$Templates = Join-Path -Path $RepoRoot -ChildPath 'templates'

if (-not (Test-Path -LiteralPath $SourceModule)) {
    throw "Cannot find module at '$SourceModule'. Run bootstrap.ps1 from the repository root."
}

if (-not (Test-Path -LiteralPath $Templates)) {
    throw "Cannot find templates at '$Templates'."
}

function Get-UserModulePath {
    if ($PSVersionTable.PSEdition -eq 'Core') {
        if ($IsWindows -or $env:OS -match 'Windows') {
            return Join-Path -Path $HOME -ChildPath 'Documents/PowerShell/Modules'
        }
        return Join-Path -Path $HOME -ChildPath '.local/share/powershell/Modules'
    }

    return Join-Path -Path $HOME -ChildPath 'Documents/WindowsPowerShell/Modules'
}

if ($Install) {
    $destination = Join-Path -Path (Get-UserModulePath) -ChildPath 'PSForge'
    if ((Test-Path -LiteralPath $destination) -and -not $Force) {
        throw "Already installed at '$destination'. Use -Force to overwrite."
    }
    if (Test-Path -LiteralPath $destination) {
        Remove-Item -LiteralPath $destination -Recurse -Force
    }

    $null = New-Item -Path $destination -ItemType Directory -Force
    Copy-Item -Path (Join-Path $SourceModule '*') -Destination $destination -Recurse -Force
    Copy-Item -Path $Templates -Destination (Join-Path $destination 'templates') -Recurse -Force

    Write-Host "Installed PSForge to $destination" -ForegroundColor Green
    Import-Module -Name $destination -Force
}
else {
    Import-Module -Name $SourceModule -Force
}

Get-Module -Name PSForge | Format-List Name, Version, Path
Write-Host @"

Ready. Examples:
  New-PSModule -Name MyTools -Path ~/Projects
  Add-PSModuleFunction -Name Get-ServerInfo -Path ~/Projects/MyTools
  Remove-PSModuleFunction -Name Get-ServerInfo -Path ~/Projects/MyTools
  Update-PSModuleVersion -Path ~/Projects/MyTools -Patch

"@ -ForegroundColor Cyan

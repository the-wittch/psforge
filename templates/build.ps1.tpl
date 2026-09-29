#Requires -Version 5.1
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string[]]$Task = @('.'),

    [Parameter()]
    [switch]$NoInstall
)

$ErrorActionPreference = 'Stop'
$ProjectRoot = $PSScriptRoot
Set-Location -Path $ProjectRoot

$modulesPath = Join-Path -Path $ProjectRoot -ChildPath '.modules'
if (-not (Test-Path -LiteralPath $modulesPath)) {
    $null = New-Item -Path $modulesPath -ItemType Directory -Force
}

$env:PSModulePath = "$modulesPath$([System.IO.Path]::PathSeparator)$env:PSModulePath"

function Test-LocalModulePresent {
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter()]
        [string]$MinimumVersion
    )

    $found = Get-Module -ListAvailable -Name $Name -ErrorAction SilentlyContinue
    if (-not $found) { return $false }
    if (-not $MinimumVersion) { return $true }
    return [bool]($found | Where-Object { $_.Version -ge [version]$MinimumVersion })
}

function Install-LocalModule {
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter()]
        [string]$MinimumVersion
    )

    if (Test-LocalModulePresent -Name $Name -MinimumVersion $MinimumVersion) {
        return
    }

    Write-Host "Installing $Name into .modules ..." -ForegroundColor Cyan
    $versionSpec = if ($MinimumVersion) { "[$MinimumVersion,)" } else { $null }

    if (Get-Command -Name Save-PSResource -ErrorAction SilentlyContinue) {
        $saveParams = @{
            Name            = $Name
            Path            = $modulesPath
            TrustRepository = $true
            ErrorAction     = 'Stop'
        }
        if ($versionSpec) { $saveParams['Version'] = $versionSpec }
        Save-PSResource @saveParams
    }
    elseif (Get-Command -Name Save-Module -ErrorAction SilentlyContinue) {
        $saveParams = @{
            Name        = $Name
            Path        = $modulesPath
            Force       = $true
            ErrorAction = 'Stop'
        }
        if ($MinimumVersion) { $saveParams['MinimumVersion'] = $MinimumVersion }
        Save-Module @saveParams
    }
    else {
        throw "Unable to install '$Name'. Install PSResourceGet or PowerShellGet, or copy modules into .modules manually."
    }
}

if (-not $NoInstall) {
    $requirementsPath = Join-Path -Path $ProjectRoot -ChildPath 'requirements.psd1'
    if (Test-Path -LiteralPath $requirementsPath) {
        $requirements = Import-PowerShellDataFile -Path $requirementsPath
        foreach ($key in $requirements.Keys) {
            $spec = $requirements[$key]
            $min = if ($spec -is [hashtable] -and $spec.ContainsKey('MinimumVersion')) {
                [string]$spec['MinimumVersion']
            }
            elseif ($spec -is [string]) {
                $spec
            }
            else {
                $null
            }
            Install-LocalModule -Name $key -MinimumVersion $min
        }
    }
}

Import-Module -Name InvokeBuild -MinimumVersion '5.0.0' -Force
$buildFile = Join-Path -Path $ProjectRoot -ChildPath 'build/{{ModuleName}}.build.ps1'
Invoke-Build -Task $Task -File $buildFile

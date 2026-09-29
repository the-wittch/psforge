#Requires -Version {{PowerShellVersion}}

$ErrorActionPreference = 'Stop'

$privatePath = Join-Path -Path $PSScriptRoot -ChildPath 'Private'
$publicPath = Join-Path -Path $PSScriptRoot -ChildPath 'Public'
$classesPath = Join-Path -Path $PSScriptRoot -ChildPath 'Classes'

if (Test-Path -LiteralPath $classesPath) {
    Get-ChildItem -Path $classesPath -Filter '*.ps1' -File | Sort-Object Name | ForEach-Object {
        . $_.FullName
    }
}

if (Test-Path -LiteralPath $privatePath) {
    Get-ChildItem -Path $privatePath -Filter '*.ps1' -File | Sort-Object Name | ForEach-Object {
        . $_.FullName
    }
}

$toExport = @()
if (Test-Path -LiteralPath $publicPath) {
    Get-ChildItem -Path $publicPath -Filter '*.ps1' -File | Sort-Object Name | ForEach-Object {
        . $_.FullName
        $toExport += $_.BaseName
    }
}

Export-ModuleMember -Function $toExport

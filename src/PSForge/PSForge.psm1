#Requires -Version 5.1

$ErrorActionPreference = 'Stop'

$script:ModuleRoot = $PSScriptRoot

$repoTemplates = Join-Path -Path (Split-Path -Path (Split-Path -Path $script:ModuleRoot -Parent) -Parent) -ChildPath 'templates'
$bundledTemplates = Join-Path -Path $script:ModuleRoot -ChildPath 'templates'

if (Test-Path -LiteralPath $repoTemplates) {
    $script:TemplateRoot = $repoTemplates
}
elseif (Test-Path -LiteralPath $bundledTemplates) {
    $script:TemplateRoot = $bundledTemplates
}
else {
    $script:TemplateRoot = $null
}

$privatePath = Join-Path -Path $PSScriptRoot -ChildPath 'Private'
$publicPath = Join-Path -Path $PSScriptRoot -ChildPath 'Public'

if (Test-Path -Path $privatePath) {
    Get-ChildItem -Path $privatePath -Filter '*.ps1' -File | ForEach-Object {
        . $_.FullName
    }
}

$publicFunctions = @()
if (Test-Path -Path $publicPath) {
    Get-ChildItem -Path $publicPath -Filter '*.ps1' -File | ForEach-Object {
        . $_.FullName
        $publicFunctions += $_.BaseName
    }
}

Export-ModuleMember -Function $publicFunctions

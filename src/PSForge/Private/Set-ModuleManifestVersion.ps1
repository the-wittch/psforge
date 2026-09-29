function Set-ModuleManifestVersion {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ManifestPath,

        [Parameter(Mandatory)]
        [version]$Version
    )

    if (-not (Test-Path -LiteralPath $ManifestPath)) {
        throw "Manifest not found: $ManifestPath"
    }

    $raw = Get-Content -LiteralPath $ManifestPath -Raw
    if ($raw -notmatch "ModuleVersion\s*=") {
        throw "ModuleVersion field not found in $ManifestPath"
    }

    $versionText = $Version.ToString()
    $updated = [regex]::Replace(
        $raw,
        "ModuleVersion\s*=\s*'[^']*'|ModuleVersion\s*=\s*""[^""]*""",
        "ModuleVersion        = '$versionText'",
        1
    )
    Write-Utf8NoBomFile -Path $ManifestPath -Value $updated
}

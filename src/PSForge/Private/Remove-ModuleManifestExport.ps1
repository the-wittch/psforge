function Remove-ModuleManifestExport {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ManifestPath,

        [Parameter(Mandatory)]
        [string]$FunctionName
    )

    if (-not (Test-Path -LiteralPath $ManifestPath)) {
        throw "Manifest not found: $ManifestPath"
    }

    $raw = Get-Content -LiteralPath $ManifestPath -Raw
    if ($raw -notmatch "FunctionsToExport\s*=\s*@\(([^\)]*)\)") {
        Write-Warning "Could not update FunctionsToExport in $ManifestPath. Remove '$FunctionName' manually."
        return
    }

    $inner = $Matches[1].Trim()
    if ([string]::IsNullOrWhiteSpace($inner)) {
        return
    }

    $names = @(
        [regex]::Matches($inner, "'([^']+)'|`"([^`"]+)`"") | ForEach-Object {
            if ($_.Groups[1].Success) { $_.Groups[1].Value } else { $_.Groups[2].Value }
        }
    ) | Where-Object { $_ -ne $FunctionName }

    $newInner = if ($names.Count -gt 0) {
        ($names | ForEach-Object { "'$_'" }) -join ', '
    }
    else {
        ''
    }

    $updated = [regex]::Replace(
        $raw,
        "FunctionsToExport\s*=\s*@\([^\)]*\)",
        "FunctionsToExport    = @($newInner)",
        1
    )
    Write-Utf8NoBomFile -Path $ManifestPath -Value $updated
}

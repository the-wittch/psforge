function Update-ModuleManifestExports {
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
    if ($raw -match [regex]::Escape("'$FunctionName'")) {
        return
    }

    if ($raw -match "FunctionsToExport\s*=\s*@\(([^\)]*)\)") {
        $inner = $Matches[1].Trim()
        if ([string]::IsNullOrWhiteSpace($inner) -or $inner -eq "''" -or $inner -eq '""') {
            $newInner = "'$FunctionName'"
        }
        else {
            $newInner = "$inner, '$FunctionName'"
        }
        $updated = [regex]::Replace(
            $raw,
            "FunctionsToExport\s*=\s*@\([^\)]*\)",
            "FunctionsToExport    = @($newInner)",
            1
        )
        Write-Utf8NoBomFile -Path $ManifestPath -Value $updated
    }
    else {
        Write-Warning "Could not update FunctionsToExport in $ManifestPath. Add '$FunctionName' manually."
    }
}

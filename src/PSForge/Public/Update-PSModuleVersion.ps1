function Update-PSModuleVersion {
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Patch')]
    [OutputType([version])]
    param(
        [Parameter(Position = 0)]
        [string]$Path = (Get-Location).Path,

        [Parameter(ParameterSetName = 'Major')]
        [switch]$Major,

        [Parameter(ParameterSetName = 'Minor')]
        [switch]$Minor,

        [Parameter(ParameterSetName = 'Patch')]
        [switch]$Patch,

        [Parameter(ParameterSetName = 'Version', Mandatory)]
        [version]$Version,

        [Parameter()]
        [switch]$PassThru
    )

    $module = Resolve-ScaffoldedModule -Path $Path
    if (-not (Test-Path -LiteralPath $module.ManifestPath)) {
        throw "Manifest not found: $($module.ManifestPath)"
    }

    $data = Import-PowerShellDataFile -Path $module.ManifestPath
    $current = [version]$data.ModuleVersion

    switch ($PSCmdlet.ParameterSetName) {
        'Major' {
            $newVersion = [version]::new($current.Major + 1, 0, 0)
        }
        'Minor' {
            $newVersion = [version]::new($current.Major, $current.Minor + 1, 0)
        }
        'Patch' {
            $build = if ($current.Build -lt 0) { 0 } else { $current.Build }
            $newVersion = [version]::new($current.Major, $current.Minor, $build + 1)
        }
        'Version' {
            $newVersion = $Version
        }
    }

    if (-not $PSCmdlet.ShouldProcess($module.ManifestPath, "Bump version $current -> $newVersion")) {
        return
    }

    Set-ModuleManifestVersion -ManifestPath $module.ManifestPath -Version $newVersion

    $changelog = Join-Path -Path $module.ProjectRoot -ChildPath 'CHANGELOG.md'
    if (Test-Path -LiteralPath $changelog) {
        $lines = [System.Collections.Generic.List[string]]::new()
        foreach ($line in (Get-Content -LiteralPath $changelog)) {
            $lines.Add([string]$line)
        }
        $bullet = "- Bump module version to $newVersion"
        $unreleasedIndex = -1
        for ($i = 0; $i -lt $lines.Count; $i++) {
            if ($lines[$i] -match '^## \[Unreleased\]') {
                $unreleasedIndex = $i
                break
            }
        }
        if ($unreleasedIndex -ge 0) {
            $changedIndex = -1
            for ($i = $unreleasedIndex + 1; $i -lt $lines.Count; $i++) {
                if ($lines[$i] -match '^## ') { break }
                if ($lines[$i] -match '^### Changed') {
                    $changedIndex = $i
                    break
                }
            }
            if ($changedIndex -ge 0) {
                $lines.Insert($changedIndex + 1, '')
                $lines.Insert($changedIndex + 2, $bullet)
            }
            else {
                $lines.Insert($unreleasedIndex + 1, '')
                $lines.Insert($unreleasedIndex + 2, '### Changed')
                $lines.Insert($unreleasedIndex + 3, '')
                $lines.Insert($unreleasedIndex + 4, $bullet)
            }
            Write-Utf8NoBomFile -Path $changelog -Value (($lines -join [Environment]::NewLine) + [Environment]::NewLine)
        }
    }

    Write-Verbose "Version $current -> $newVersion"

    if ($PassThru) {
        $newVersion
    }
}

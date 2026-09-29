function Remove-PSModuleFunction {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    [OutputType([string])]
    param(
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Position = 1)]
        [string]$Path = (Get-Location).Path,

        [Parameter()]
        [switch]$Private,

        [Parameter()]
        [switch]$PassThru
    )

    Assert-ValidCommandName -Name $Name

    $module = Resolve-ScaffoldedModule -Path $Path

    $candidates = @()
    if ($Private) {
        $candidates += Join-Path -Path $module.ModuleDir -ChildPath "Private/$Name.ps1"
    }
    else {
        $publicPath = Join-Path -Path $module.ModuleDir -ChildPath "Public/$Name.ps1"
        $privatePath = Join-Path -Path $module.ModuleDir -ChildPath "Private/$Name.ps1"
        if (Test-Path -LiteralPath $publicPath) { $candidates += $publicPath }
        if (Test-Path -LiteralPath $privatePath) { $candidates += $privatePath }
    }

    $existing = @($candidates | Where-Object { Test-Path -LiteralPath $_ })
    if ($existing.Count -eq 0) {
        throw "Function '$Name' not found under Public/ or Private/ in '$($module.ModuleDir)'."
    }
    if ($existing.Count -gt 1) {
        throw "Function '$Name' exists in both Public/ and Private/. Re-run with -Private to target the private copy."
    }

    $functionPath = $existing[0]
    $isPublic = $functionPath -match '[\\/]Public[\\/]'

    if ($PSCmdlet.ShouldProcess($functionPath, "Remove function $Name")) {
        Remove-Item -LiteralPath $functionPath -Force

        if ($isPublic) {
            $testPath = Join-Path -Path $module.ProjectRoot -ChildPath "tests/Unit/Public/$Name.Tests.ps1"
            if (Test-Path -LiteralPath $testPath) {
                Remove-Item -LiteralPath $testPath -Force
            }
            Remove-ModuleManifestExport -ManifestPath $module.ManifestPath -FunctionName $Name
        }

        if ($PassThru) {
            $functionPath
        }
    }
}

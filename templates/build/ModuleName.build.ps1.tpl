#Requires -Modules @{ ModuleName = 'InvokeBuild'; ModuleVersion = '5.12.1' }

$ProjectRoot = (Resolve-Path -Path (Join-Path $BuildRoot '..')).Path
$ModuleName = '{{ModuleName}}'
$SourceRoot = Join-Path $ProjectRoot "src/$ModuleName"
$OutputRoot = Join-Path $ProjectRoot 'output'
$BuiltModule = Join-Path $OutputRoot $ModuleName
$AnalyzerSettings = Join-Path $ProjectRoot 'PSScriptAnalyzerSettings.psd1'
$TestsRoot = Join-Path $ProjectRoot 'tests'

task . Clean, Analyze, TestUnit, Build, TestIntegration

task Clean {
    if (Test-Path -LiteralPath $OutputRoot) {
        Remove-Item -LiteralPath $OutputRoot -Recurse -Force
    }
    $null = New-Item -Path $BuiltModule -ItemType Directory -Force
}

task Analyze {
    Import-Module PSScriptAnalyzer -Force
    $results = Invoke-ScriptAnalyzer -Path $SourceRoot -Settings $AnalyzerSettings -Recurse
    if ($results) {
        $results | Format-Table -AutoSize
        throw "PSScriptAnalyzer found $($results.Count) issue(s)."
    }
    Write-Build Green 'PSScriptAnalyzer: no issues'
}

task TestUnit {
    Import-Module Pester -MinimumVersion 5.0.0 -Force
    $config = New-PesterConfiguration
    $config.Run.Path = Join-Path $TestsRoot 'Unit'
    $config.Run.Exit = $true
    $config.Output.Verbosity = 'Detailed'
    $config.TestResult.Enabled = $true
    $config.TestResult.OutputPath = Join-Path $OutputRoot 'testResults.unit.xml'
    $config.TestResult.OutputFormat = 'NUnitXml'

    $env:PSMODULE_UNDER_TEST = $SourceRoot
    Invoke-Pester -Configuration $config
}

task Build {
    $publicDir = Join-Path $SourceRoot 'Public'
    $privateDir = Join-Path $SourceRoot 'Private'
    $classesDir = Join-Path $SourceRoot 'Classes'

    $sb = [System.Text.StringBuilder]::new()
    [void]$sb.AppendLine('#Requires -Version {{PowerShellVersion}}')
    [void]$sb.AppendLine('$ErrorActionPreference = ''Stop''')
    [void]$sb.AppendLine()

    foreach ($dir in @($classesDir, $privateDir, $publicDir)) {
        if (-not (Test-Path -LiteralPath $dir)) { continue }
        Get-ChildItem -Path $dir -Filter '*.ps1' -File | Sort-Object Name | ForEach-Object {
            [void]$sb.AppendLine((Get-Content -LiteralPath $_.FullName -Raw))
            [void]$sb.AppendLine()
        }
    }

    $publicFunctions = @()
    if (Test-Path -LiteralPath $publicDir) {
        $publicFunctions = @(
            Get-ChildItem -Path $publicDir -Filter '*.ps1' -File | Sort-Object Name | ForEach-Object { $_.BaseName }
        )
    }

    $exportList = ($publicFunctions | ForEach-Object { "'$_'" }) -join ', '
    if (-not $exportList) { $exportList = '' }
    [void]$sb.AppendLine("Export-ModuleMember -Function @($exportList)")

    $psm1Path = Join-Path $BuiltModule "$ModuleName.psm1"
    $encoding = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($psm1Path, $sb.ToString(), $encoding)

    $srcManifest = Join-Path $SourceRoot "$ModuleName.psd1"
    $dstManifest = Join-Path $BuiltModule "$ModuleName.psd1"
    Copy-Item -LiteralPath $srcManifest -Destination $dstManifest -Force

    $manifestContent = Get-Content -LiteralPath $dstManifest -Raw
    $exportArray = if ($publicFunctions.Count -gt 0) {
        '@(' + (($publicFunctions | ForEach-Object { "'$_'" }) -join ', ') + ')'
    }
    else {
        '@()'
    }
    $manifestContent = [regex]::Replace(
        $manifestContent,
        "FunctionsToExport\s*=\s*@\([^\)]*\)",
        "FunctionsToExport    = $exportArray"
    )
    [System.IO.File]::WriteAllText($dstManifest, $manifestContent, $encoding)

    Write-Build Green "Built module -> $BuiltModule"
}

task TestIntegration Build, {
    Import-Module Pester -MinimumVersion 5.0.0 -Force
    $config = New-PesterConfiguration
    $config.Run.Path = Join-Path $TestsRoot 'Integration'
    $config.Run.Exit = $true
    $config.Output.Verbosity = 'Detailed'
    $config.TestResult.Enabled = $true
    $config.TestResult.OutputPath = Join-Path $OutputRoot 'testResults.integration.xml'
    $config.TestResult.OutputFormat = 'NUnitXml'

    $env:PSMODULE_UNDER_TEST = $BuiltModule
    Invoke-Pester -Configuration $config
}

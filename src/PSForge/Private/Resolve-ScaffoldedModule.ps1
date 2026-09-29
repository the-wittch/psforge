function Resolve-ScaffoldedModule {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    $projectRoot = (Resolve-Path -Path $Path).Path
    $srcRoot = Join-Path -Path $projectRoot -ChildPath 'src'

    if (-not (Test-Path -LiteralPath $srcRoot)) {
        throw "Path '$projectRoot' does not look like a scaffolded module project (missing src/)."
    }

    $moduleDir = Get-ChildItem -LiteralPath $srcRoot -Directory | Select-Object -First 1
    if (-not $moduleDir) {
        throw "No module directory found under '$srcRoot'."
    }

    $moduleName = $moduleDir.Name
    $manifestPath = Join-Path -Path $moduleDir.FullName -ChildPath "$moduleName.psd1"

    return @{
        ProjectRoot  = $projectRoot
        ModuleDir    = $moduleDir.FullName
        ModuleName   = $moduleName
        ManifestPath = $manifestPath
    }
}

function Add-PSModuleFunction {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([System.IO.FileInfo])]
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
    $scope = if ($Private) { 'Private' } else { 'Public' }
    $functionDir = Join-Path -Path $module.ModuleDir -ChildPath $scope
    $functionPath = Join-Path -Path $functionDir -ChildPath "$Name.ps1"

    if (Test-Path -LiteralPath $functionPath) {
        throw "Function file already exists: $functionPath"
    }

    $templateRoot = Get-TemplateRoot
    $tokens = @{
        ModuleName     = $module.ModuleName
        SampleFunction = $Name
        Author         = $env:USERNAME
        Description    = "Function $Name."
        Year           = (Get-Date).Year.ToString()
    }

    if (-not $tokens['Author']) {
        $tokens['Author'] = 'Unknown'
    }

    if ($PSCmdlet.ShouldProcess($functionPath, "Add $scope function $Name")) {
        $null = New-Item -Path $functionDir -ItemType Directory -Force

        if ($Private) {
            $tpl = Join-Path -Path $templateRoot -ChildPath 'src/ModuleName/Private/Helper.ps1.tpl'
        }
        else {
            $tpl = Join-Path -Path $templateRoot -ChildPath 'src/ModuleName/Public/Get-Sample.ps1.tpl'
        }

        $content = Get-TemplateContent -TemplatePath $tpl -Tokens $tokens
        Write-Utf8NoBomFile -Path $functionPath -Value $content

        if (-not $Private) {
            $testDir = Join-Path -Path $module.ProjectRoot -ChildPath 'tests/Unit/Public'
            $null = New-Item -Path $testDir -ItemType Directory -Force
            $testPath = Join-Path -Path $testDir -ChildPath "$Name.Tests.ps1"
            $testTpl = Join-Path -Path $templateRoot -ChildPath 'tests/Unit/Public/Get-Sample.Tests.ps1.tpl'
            $testContent = Get-TemplateContent -TemplatePath $testTpl -Tokens $tokens
            Write-Utf8NoBomFile -Path $testPath -Value $testContent
            Update-ModuleManifestExports -ManifestPath $module.ManifestPath -FunctionName $Name
        }

        if ($PassThru) {
            Get-Item -LiteralPath $functionPath
        }
    }
}

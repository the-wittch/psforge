function New-ModuleTree {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$DestinationPath,

        [Parameter(Mandatory)]
        [hashtable]$Tokens,

        [Parameter(Mandatory)]
        [string]$SampleFunctionName
    )

    $templateRoot = Get-TemplateRoot
    $moduleName = $Tokens['ModuleName']

    $directories = @(
        (Join-Path $DestinationPath "src/$moduleName/Public")
        (Join-Path $DestinationPath "src/$moduleName/Private")
        (Join-Path $DestinationPath "src/$moduleName/Classes")
        (Join-Path $DestinationPath 'build')
        (Join-Path $DestinationPath 'tests/Unit/Public')
        (Join-Path $DestinationPath 'tests/Integration')
        (Join-Path $DestinationPath 'docs')
        (Join-Path $DestinationPath '.github/workflows')
        (Join-Path $DestinationPath '.vscode')
    )

    foreach ($dir in $directories) {
        $null = New-Item -Path $dir -ItemType Directory -Force
    }

    $null = New-Item -Path (Join-Path $DestinationPath "src/$moduleName/Private/.gitkeep") -ItemType File -Force
    $null = New-Item -Path (Join-Path $DestinationPath "src/$moduleName/Classes/.gitkeep") -ItemType File -Force
    $null = New-Item -Path (Join-Path $DestinationPath 'docs/.gitkeep') -ItemType File -Force

    $fileMap = [ordered]@{
        'src/ModuleName/ModuleName.psd1.tpl'        = "src/$moduleName/$moduleName.psd1"
        'src/ModuleName/ModuleName.psm1.tpl'        = "src/$moduleName/$moduleName.psm1"
        'src/ModuleName/Public/Get-Sample.ps1.tpl'   = "src/$moduleName/Public/$SampleFunctionName.ps1"
        'build/ModuleName.build.ps1.tpl'            = "build/$moduleName.build.ps1"
        'build.ps1.tpl'                             = 'build.ps1'
        'tests/Unit/Public/Get-Sample.Tests.ps1.tpl' = "tests/Unit/Public/$SampleFunctionName.Tests.ps1"
        'tests/Integration/Module.Tests.ps1.tpl'    = 'tests/Integration/Module.Tests.ps1'
        'PSScriptAnalyzerSettings.psd1.tpl'         = 'PSScriptAnalyzerSettings.psd1'
        'requirements.psd1.tpl'                     = 'requirements.psd1'
        'gitignore.tpl'                             = '.gitignore'
        'editorconfig.tpl'                          = '.editorconfig'
        '.vscode/extensions.json.tpl'               = '.vscode/extensions.json'
        '.github/workflows/ci.yml.tpl'              = '.github/workflows/ci.yml'
        'README.md.tpl'                             = 'README.md'
        'CHANGELOG.md.tpl'                          = 'CHANGELOG.md'
        'LICENSE.tpl'                               = 'LICENSE'
        'CONTRIBUTING.md.tpl'                       = 'CONTRIBUTING.md'
    }

    foreach ($relativeTemplate in $fileMap.Keys) {
        $source = Join-Path -Path $templateRoot -ChildPath $relativeTemplate
        $dest = Join-Path -Path $DestinationPath -ChildPath $fileMap[$relativeTemplate]
        $content = Get-TemplateContent -TemplatePath $source -Tokens $Tokens
        Write-Utf8NoBomFile -Path $dest -Value $content
    }
}

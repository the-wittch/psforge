BeforeAll {
    $repoRoot = (Resolve-Path -Path (Join-Path $PSScriptRoot '..')).Path
    $modulePath = Join-Path -Path $repoRoot -ChildPath 'src/PSForge'
    Import-Module -Name $modulePath -Force
}

Describe 'PSForge module' {
    It 'Exports expected commands' {
        @(
            'New-PSModule'
            'Add-PSModuleFunction'
            'Remove-PSModuleFunction'
            'Update-PSModuleVersion'
        ) | ForEach-Object {
            Get-Command -Name $_ -Module PSForge | Should -Not -BeNullOrEmpty
        }
    }
}

Describe 'New-PSModule' {
    BeforeEach {
        $script:tempRoot = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath ("PSForge-" + [guid]::NewGuid().ToString('N'))
        $null = New-Item -Path $script:tempRoot -ItemType Directory -Force
    }

    AfterEach {
        if ($script:tempRoot -and (Test-Path -LiteralPath $script:tempRoot)) {
            Remove-Item -LiteralPath $script:tempRoot -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    It 'Rejects invalid module names' {
        { New-PSModule -Name '1Bad' -Path $script:tempRoot } | Should -Throw
        { New-PSModule -Name 'Bad Name' -Path $script:tempRoot } | Should -Throw
    }

    It 'Scaffolds the expected project tree' {
        $project = New-PSModule -Name 'DemoTools' -Path $script:tempRoot -Author 'Pester' -Description 'Test module' -PassThru
        $root = $project.FullName

        $expected = @(
            "src/DemoTools/DemoTools.psd1"
            "src/DemoTools/DemoTools.psm1"
            "src/DemoTools/Public/Get-DemoToolsExample.ps1"
            "src/DemoTools/Private/.gitkeep"
            "src/DemoTools/Classes/.gitkeep"
            "build/DemoTools.build.ps1"
            "build.ps1"
            "tests/Unit/Public/Get-DemoToolsExample.Tests.ps1"
            "tests/Integration/Module.Tests.ps1"
            "PSScriptAnalyzerSettings.psd1"
            "requirements.psd1"
            ".gitignore"
            ".editorconfig"
            ".vscode/extensions.json"
            ".github/workflows/ci.yml"
            "README.md"
            "CHANGELOG.md"
            "LICENSE"
            "CONTRIBUTING.md"
            "docs/.gitkeep"
        )

        foreach ($rel in $expected) {
            $full = Join-Path -Path $root -ChildPath $rel
            Test-Path -LiteralPath $full | Should -BeTrue -Because $rel
        }
    }

    It 'Emits nothing without -PassThru' {
        $result = New-PSModule -Name 'QuietModule' -Path $script:tempRoot
        $result | Should -BeNullOrEmpty
        Test-Path -LiteralPath (Join-Path $script:tempRoot 'QuietModule') | Should -BeTrue
    }

    It 'Replaces template tokens in the manifest' {
        New-PSModule -Name 'TokenCheck' -Path $script:tempRoot -Author 'Ada' -Description 'Tokenized'
        $manifestPath = Join-Path -Path $script:tempRoot -ChildPath 'TokenCheck/src/TokenCheck/TokenCheck.psd1'
        $raw = Get-Content -LiteralPath $manifestPath -Raw
        $raw | Should -Not -Match '\{\{'
        $raw | Should -Match 'Ada'
        $raw | Should -Match 'Tokenized'
        $data = Import-PowerShellDataFile -Path $manifestPath
        $data.RootModule | Should -Be 'TokenCheck.psm1'
        $data.ModuleVersion | Should -Be '0.1.0'
    }

    It 'Produces a loadable source module with the sample command' {
        New-PSModule -Name 'LoadMe' -Path $script:tempRoot -Author 'Test'
        $src = Join-Path -Path $script:tempRoot -ChildPath 'LoadMe/src/LoadMe'
        Import-Module -Name $src -Force
        Get-Command -Name Get-LoadMeExample -Module LoadMe | Should -Not -BeNullOrEmpty
        Get-LoadMeExample -Name 'CI' | Should -Match 'CI'
        Remove-Module -Name LoadMe -Force -ErrorAction SilentlyContinue
    }

    It 'Supports -Force to overwrite an existing project' {
        New-PSModule -Name 'OverwriteMe' -Path $script:tempRoot
        $marker = Join-Path -Path $script:tempRoot -ChildPath 'OverwriteMe/MARKER.txt'
        Set-Content -Path $marker -Value 'stale'
        New-PSModule -Name 'OverwriteMe' -Path $script:tempRoot -Force
        Test-Path -LiteralPath $marker | Should -BeFalse
        Test-Path -LiteralPath (Join-Path $script:tempRoot 'OverwriteMe/build.ps1') | Should -BeTrue
    }
}

Describe 'Add-PSModuleFunction and Remove-PSModuleFunction' {
    BeforeAll {
        $script:addRoot = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath ("PSForge-Add-" + [guid]::NewGuid().ToString('N'))
        $null = New-Item -Path $script:addRoot -ItemType Directory -Force
        New-PSModule -Name 'FuncHost' -Path $script:addRoot -Author 'Test'
        $script:project = Join-Path -Path $script:addRoot -ChildPath 'FuncHost'
    }

    AfterAll {
        Remove-Module -Name FuncHost -Force -ErrorAction SilentlyContinue
        if ($script:addRoot -and (Test-Path -LiteralPath $script:addRoot)) {
            Remove-Item -LiteralPath $script:addRoot -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    It 'Adds a public function and unit test' {
        $file = Add-PSModuleFunction -Name 'Get-HostInfo' -Path $script:project -PassThru
        $file.Name | Should -Be 'Get-HostInfo.ps1'
        Test-Path -LiteralPath (Join-Path $script:project 'src/FuncHost/Public/Get-HostInfo.ps1') | Should -BeTrue
        Test-Path -LiteralPath (Join-Path $script:project 'tests/Unit/Public/Get-HostInfo.Tests.ps1') | Should -BeTrue
    }

    It 'Adds a private function without a unit test' {
        Add-PSModuleFunction -Name 'Get-SecretThing' -Path $script:project -Private
        Test-Path -LiteralPath (Join-Path $script:project 'src/FuncHost/Private/Get-SecretThing.ps1') | Should -BeTrue
        Test-Path -LiteralPath (Join-Path $script:project 'tests/Unit/Public/Get-SecretThing.Tests.ps1') | Should -BeFalse
    }

    It 'Rejects invalid command names' {
        { Add-PSModuleFunction -Name 'NotAValidName' -Path $script:project } | Should -Throw
    }

    It 'Removes a public function, test, and manifest export' {
        Remove-PSModuleFunction -Name 'Get-HostInfo' -Path $script:project -Confirm:$false
        Test-Path -LiteralPath (Join-Path $script:project 'src/FuncHost/Public/Get-HostInfo.ps1') | Should -BeFalse
        Test-Path -LiteralPath (Join-Path $script:project 'tests/Unit/Public/Get-HostInfo.Tests.ps1') | Should -BeFalse
        $manifest = Get-Content -LiteralPath (Join-Path $script:project 'src/FuncHost/FuncHost.psd1') -Raw
        $manifest | Should -Not -Match "Get-HostInfo"
    }

    It 'Removes a private function' {
        Remove-PSModuleFunction -Name 'Get-SecretThing' -Path $script:project -Private -Confirm:$false
        Test-Path -LiteralPath (Join-Path $script:project 'src/FuncHost/Private/Get-SecretThing.ps1') | Should -BeFalse
    }
}

Describe 'Update-PSModuleVersion' {
    BeforeEach {
        $script:verRoot = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath ("PSForge-Ver-" + [guid]::NewGuid().ToString('N'))
        $null = New-Item -Path $script:verRoot -ItemType Directory -Force
        New-PSModule -Name 'VerHost' -Path $script:verRoot -Author 'Test'
        $script:project = Join-Path -Path $script:verRoot -ChildPath 'VerHost'
    }

    AfterEach {
        if ($script:verRoot -and (Test-Path -LiteralPath $script:verRoot)) {
            Remove-Item -LiteralPath $script:verRoot -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    It 'Bumps patch by default' {
        $version = Update-PSModuleVersion -Path $script:project -PassThru
        $version | Should -Be ([version]'0.1.1')
        $data = Import-PowerShellDataFile -Path (Join-Path $script:project 'src/VerHost/VerHost.psd1')
        $data.ModuleVersion | Should -Be '0.1.1'
    }

    It 'Bumps minor and resets patch' {
        $version = Update-PSModuleVersion -Path $script:project -Minor -PassThru
        $version | Should -Be ([version]'0.2.0')
    }

    It 'Bumps major and resets minor/patch' {
        $version = Update-PSModuleVersion -Path $script:project -Major -PassThru
        $version | Should -Be ([version]'1.0.0')
    }

    It 'Sets an explicit version' {
        $version = Update-PSModuleVersion -Path $script:project -Version '2.3.4' -PassThru
        $version | Should -Be ([version]'2.3.4')
    }

    It 'Records the bump in CHANGELOG' {
        Update-PSModuleVersion -Path $script:project -Patch
        $log = Get-Content -LiteralPath (Join-Path $script:project 'CHANGELOG.md') -Raw
        $log | Should -Match 'Bump module version to 0\.1\.1'
    }
}

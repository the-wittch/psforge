@{
    RootModule           = 'PSForge.psm1'
    ModuleVersion        = '0.1.0'
    GUID                 = 'a7c4e2f1-8b3d-4e6a-9c1f-2d5e8a0b4c7d'
    Author               = 'PSForge Contributors'
    CompanyName          = 'Community'
    Copyright            = '(c) PSForge Contributors. All rights reserved.'
    Description          = 'Scaffold production-ready PowerShell modules. Clone from GitHub — no PowerShell Gallery required.'
    PowerShellVersion    = '5.1'
    FunctionsToExport    = @(
        'New-PSModule'
        'Add-PSModuleFunction'
        'Remove-PSModuleFunction'
        'Update-PSModuleVersion'
    )
    CmdletsToExport      = @()
    VariablesToExport    = @()
    AliasesToExport      = @()
    PrivateData          = @{
        PSData = @{
            Tags         = @('Scaffold', 'Module', 'Pester', 'PSScriptAnalyzer', 'InvokeBuild', 'BestPractices')
            LicenseUri   = 'https://opensource.org/licenses/MIT'
            ProjectUri   = 'https://github.com/the-wittch/psforge'
            ReleaseNotes = 'New-PSModule, Add/Remove-PSModuleFunction, Update-PSModuleVersion.'
        }
    }
}

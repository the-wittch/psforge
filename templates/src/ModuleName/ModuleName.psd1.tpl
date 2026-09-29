@{
    RootModule           = '{{ModuleName}}.psm1'
    ModuleVersion        = '{{Version}}'
    GUID                 = '{{Guid}}'
    Author               = '{{Author}}'
    CompanyName          = '{{CompanyName}}'
    Copyright            = '(c) {{Year}} {{Author}}. All rights reserved.'
    Description          = '{{Description}}'
    PowerShellVersion    = '{{PowerShellVersion}}'
    FunctionsToExport    = @('{{SampleFunction}}')
    CmdletsToExport      = @()
    VariablesToExport    = @()
    AliasesToExport      = @()
    PrivateData          = @{
        PSData = @{
            Tags         = @('PowerShell', 'Module')
            LicenseUri   = 'https://opensource.org/licenses/MIT'
            ProjectUri   = ''
            ReleaseNotes = 'Initial scaffolded release.'
        }
    }
}

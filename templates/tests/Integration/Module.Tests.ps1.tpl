BeforeAll {
    $modulePath = $env:PSMODULE_UNDER_TEST
    if (-not $modulePath) {
        $modulePath = Join-Path -Path $PSScriptRoot -ChildPath '../../../output/{{ModuleName}}'
    }
    Import-Module -Name $modulePath -Force
}

Describe '{{ModuleName}} module' {
    It 'Imports without error' {
        Get-Module -Name '{{ModuleName}}' | Should -Not -BeNullOrEmpty
    }

    It 'Exports the sample function' {
        Get-Command -Name '{{SampleFunction}}' -Module '{{ModuleName}}' |
            Should -Not -BeNullOrEmpty
    }

    It 'Exports only Public commands by name list' {
        $exported = @(Get-Command -Module '{{ModuleName}}' | Select-Object -ExpandProperty Name)
        $exported | Should -Contain '{{SampleFunction}}'
    }
}

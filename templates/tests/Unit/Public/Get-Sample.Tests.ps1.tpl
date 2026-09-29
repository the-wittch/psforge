BeforeAll {
    $modulePath = $env:PSMODULE_UNDER_TEST
    if (-not $modulePath) {
        $modulePath = Join-Path -Path $PSScriptRoot -ChildPath '../../../../src/{{ModuleName}}'
    }
    Import-Module -Name $modulePath -Force
}

Describe '{{SampleFunction}}' {
    It 'Returns a greeting for a given name' {
        $result = {{SampleFunction}} -Name 'Pester'
        $result | Should -Match 'Pester'
    }

    It 'Accepts pipeline input' {
        $result = 'Ada' | {{SampleFunction}}
        $result | Should -Match 'Ada'
    }

    It 'Uses a default name when none is supplied' {
        $result = {{SampleFunction}}
        $result | Should -Match 'World'
    }
}

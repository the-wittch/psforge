@{
    Severity     = @('Error', 'Warning')
    IncludeRules = @(
        'PSAvoidDefaultValueSwitchParameter'
        'PSAvoidGlobalVars'
        'PSAvoidUsingCmdletAliases'
        'PSAvoidUsingComputerNameHardcoded'
        'PSAvoidUsingConvertToSecureStringWithPlainText'
        'PSAvoidUsingEmptyCatchBlock'
        'PSAvoidUsingInvokeExpression'
        'PSAvoidUsingPlainTextForPassword'
        'PSAvoidUsingPositionalParameters'
        'PSAvoidUsingWMICmdlet'
        'PSAvoidUsingWriteHost'
        'PSMissingModuleManifestField'
        'PSReservedCmdletChar'
        'PSReservedParams'
        'PSUseApprovedVerbs'
        'PSUseCmdletCorrectly'
        'PSUseDeclaredVarsMoreThanAssignments'
        'PSUseOutputTypeCorrectly'
        'PSUseShouldProcessForStateChangingFunctions'
        'PSUseSingularNouns'
        'PSUseToExportFieldsInManifest'
    )
    ExcludeRules = @()
    Rules        = @{
        PSUseCompatibleCmdlets = @{
            compatibility = @('desktop_5.1.14393.206', 'core_7.0.0_linux', 'core_7.0.0_windows')
        }
    }
}

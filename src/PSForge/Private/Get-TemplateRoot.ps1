function Get-TemplateRoot {
    [CmdletBinding()]
    [OutputType([string])]
    param()

    if ($script:TemplateRoot -and (Test-Path -LiteralPath $script:TemplateRoot)) {
        return $script:TemplateRoot
    }

    throw 'Unable to locate the PSForge templates directory. Re-clone the repository or re-run bootstrap.ps1 -Install.'
}

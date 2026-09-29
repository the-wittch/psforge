function Get-TemplateContent {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [string]$TemplatePath,

        [Parameter(Mandatory)]
        [hashtable]$Tokens
    )

    if (-not (Test-Path -Path $TemplatePath)) {
        throw "Template not found: $TemplatePath"
    }

    $content = Get-Content -Path $TemplatePath -Raw -ErrorAction Stop

    foreach ($key in $Tokens.Keys) {
        $pattern = '{{' + $key + '}}'
        $content = $content.Replace($pattern, [string]$Tokens[$key])
    }

    return $content
}

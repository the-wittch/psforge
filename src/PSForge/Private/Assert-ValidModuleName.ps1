function Assert-ValidModuleName {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    if ($Name -notmatch '^[A-Za-z][A-Za-z0-9._-]*$') {
        throw "Invalid module name '$Name'. Names must start with a letter and contain only letters, digits, dots, underscores, or hyphens."
    }

    if ($Name.Length -gt 64) {
        throw "Module name '$Name' exceeds 64 characters."
    }
}

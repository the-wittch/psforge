function Assert-ValidCommandName {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    if ($Name -notmatch '^[A-Za-z][A-Za-z0-9]*-[A-Za-z][A-Za-z0-9]*$') {
        throw "Invalid command name '$Name'. Use Verb-Noun form (letters and digits only), for example Get-ItemInfo."
    }

    $verb = ($Name -split '-', 2)[0]
    $approved = Get-Verb | Select-Object -ExpandProperty Verb
    if ($approved -notcontains $verb) {
        Write-Warning "Verb '$verb' is not an approved PowerShell verb. Run Get-Verb for the approved list."
    }
}

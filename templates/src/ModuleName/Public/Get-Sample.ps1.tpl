function {{SampleFunction}} {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $false, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$Name = 'World'
    )

    begin {}

    process {
        "Hello, $Name! (from {{ModuleName}})"
    }

    end {}
}

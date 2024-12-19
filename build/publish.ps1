[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]$ModulePath,
    [string]$ApiKey

)

Publish-Module -Path $ModulePath -NuGetApiKey $ApiKey -WhatIf
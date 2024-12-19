[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]$ApiKey

)
$manifest = Get-ChildItem -Recurse | Where-Object { $_.Name -like "*.psd1" }

Publish-Module -Path $manifest.DirectoryName -NuGetApiKey $ApiKey -WhatIf
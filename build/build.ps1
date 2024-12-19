[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]$ModulePath,
    [version]$Version,
    [string]$PreReleaseTag

)

Write-Output (Get-ChildItem -Recurse)

$manifest = Get-ChildItem -Recurse | Where-Object { $_.Name -like "*.psd1" }

# get public functions to export
$pubFunctions = ((Get-ChildItem *ps1 -Recurse | Where-Object { $_.DirectoryName -like "*public*" }).Name).Replace(".ps1", "")

Write-Output "updating module manifest $($manifest.FullName) to version $Version"

if ($PreReleaseTag) {
    Update-ModuleManifest -Path $manifest.FullName -FunctionsToExport $pubFunctions -ModuleVersion $Version -Prerelease $PreReleaseTag
}
else {
    Update-ModuleManifest -Path $manifest.FullName -FunctionsToExport $pubFunctions -ModuleVersion $Version
}

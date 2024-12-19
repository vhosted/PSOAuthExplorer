[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]$ModulePath,
    [version]$Version,
    [string]$PreReleaseTag

)

$manifest = Get-ChildItem -Recurse | Where-Object { $_.Name -like "*.psd1" }

# get public functions to export
$pubFunctions = ((Get-ChildItem "$($manifest.DirectoryName)\public\*.ps1" -Recurse).Name).Replace(".ps1", "")

if ($PreReleaseTag) {
    Update-ModuleManifest -Path $manifest.FullName -FunctionsToExport $pubFunctions -ModuleVersion $Version -Prerelease $PreReleaseTag
}
else {
    Update-ModuleManifest -Path $manifest.FullName -FunctionsToExport $pubFunctions -ModuleVersion $Version
}

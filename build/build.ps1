[CmdletBinding()]
param (
    [version]$Version,
    [string]$PreReleaseTag

)

$manifest = Get-ChildItem -Recurse | Where-Object { $_.Name -like "*.psd1" }

# get public functions to export
$pubFunctions = ((Get-ChildItem *.ps1 -Recurse | Where-Object { $_.DirectoryName -like "*Public*" }).Name).Replace(".ps1", "")

if ($PreReleaseTag) {
    Update-ModuleManifest -Path $manifest.FullName -FunctionsToExport $pubFunctions -ModuleVersion $Version -Prerelease $PreReleaseTag
}
else {
    Update-ModuleManifest -Path $manifest.FullName -FunctionsToExport $pubFunctions -ModuleVersion $Version
}

Write-Output "updated module manifest $($manifest.FullName) to version $Version"

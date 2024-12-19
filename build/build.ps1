[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]$ModulePath,
    [version]$Version,
    [string]$PreReleaseTag

)

$manifest = Get-ChildItem "$ModulePath\*.psd1"
$moduleName = $manifest.Name -replace ".psd1"



# get functions
$pubFunctions = ((Get-ChildItem $ModulePath\public\*.ps1 -Recurse).Name).Replace(".ps1", "")

if ($PreReleaseTag) {
    Update-ModuleManifest -Path $manifest.FullName -FunctionsToExport $pubFunctions -ModuleVersion $Version -Prerelease $PreReleaseTag
}
Update-ModuleManifest -Path $manifest.FullName -FunctionsToExport $pubFunctions -ModuleVersion $Version

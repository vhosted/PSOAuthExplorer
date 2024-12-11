# Import functions
Get-ChildItem -Path $PSScriptRoot\Functions\*.ps1 | ForEach-Object { . $_.FullName }

# Import helper functions
Get-ChildItem -Path $PSScriptRoot\Helper\*.ps1 | ForEach-Object { . $_.FullName }

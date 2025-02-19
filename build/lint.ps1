[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]$Path
)
#lint.ps1 -Path "..\src\*\*.ps1"
Invoke-ScriptAnalyzer -Path $Path -Recurse -OutVariable issues -Verbose

$errors = $issues | Where-Object { $_.Severity -eq "Error" }
$warnings = $issues | Where-Object { $_.Severity -eq "Warning" }

if ($errors) {
    Write-Error "ScriptAnalyzer found $($errors.Count) errors and $($warnings.Count) warnings." -ErrorAction Stop
}
else {
    Write-Output "ScriptAnalyzer found $($errors.Count) errors and $($warnings.Count) warnings."
}



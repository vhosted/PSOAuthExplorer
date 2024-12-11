@{
    ModuleVersion      = '1.0.0'
    GUID               = 'your-guid-here'
    Author             = 'Your Name'
    Description        = 'A PowerShell module for exploring OAuth2 and OIDC flows.'
    FunctionsToExport  = @(
        'Get-AuthCode',
        'Get-AccessToken',
        'Start-HttpListener',
        'Encode-Url'
    )
    RequiredModules    = @()
    RequiredAssemblies = @()
    ScriptsToProcess   = @()
    TypesToProcess     = @()
    FormatsToProcess   = @()
    PrivateData        = @{
        PSData = @{
            Tags       = @('OAuth2', 'OIDC', 'Authentication', 'PowerShell')
            LicenseUri = 'https://opensource.org/licenses/MIT'
            ProjectUri = 'https://github.com/your-repo'
            IconUri    = 'https://your-icon-uri'
        }
    }
}

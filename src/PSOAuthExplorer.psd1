@{
    ModuleVersion      = '1.0.0'
    GUID               = '89cfd7d2-da56-4e46-9c7a-3aa142ae6e20'
    Author             = 'Janick Marbot'
    Description        = 'A PowerShell module for exploring OAuth2 and OIDC flows.'
    RootModule         = 'PSOAuthExplorer.psm1'
    FunctionsToExport  = '*'
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

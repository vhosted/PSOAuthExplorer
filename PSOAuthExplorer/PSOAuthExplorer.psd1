@{
    ModuleVersion      = '0.1.0'
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
            ProjectUri = 'https://github.com/vhosted-xyz/PSOAuthExplorer'
        }
    }
}
GUID = '89cfd7d2-da56-4e46-9c7a-3aa142ae6e20'

# Author of this module
Author = 'Janick Marbot'

# Company or vendor of this module
CompanyName = ''

# Copyright statement for this module
Copyright = '(c) Janick Marbot. All rights reserved.'

# Description of the functionality provided by this module
Description = 'A PowerShell module for exploring OAuth2 and OIDC flows.'

# Minimum version of the PowerShell engine required by this module
# PowerShellVersion = ''

# Name of the PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# ClrVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
# NestedModules = @()

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = 'Get-AccessToken', 'Get-AuthorizationCode', 'Get-MsftTenantId', 
               'Invoke-AuthorizationCodeFlow', 'Invoke-ClientCredentialsFlow', 
               'Invoke-DeviceAuthorizationFlow'

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = @()

# Variables to export from this module
# VariablesToExport = @()

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = @()

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
# FileList = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = 'OAuth2','OIDC','Authentication','PowerShell'

        # A URL to the license for this module.
        LicenseUri = 'https://opensource.org/licenses/MIT'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/vhosted/PSOAuthExplorer'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        # ReleaseNotes = ''

        # Prerelease string of this module
        # Prerelease = ''

        # Flag to indicate whether the module requires explicit user acceptance for install/update/save
        # RequireLicenseAcceptance = $false

        # External dependent modules of this module
        # ExternalModuleDependencies = @()

    } # End of PSData hashtable

 } # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

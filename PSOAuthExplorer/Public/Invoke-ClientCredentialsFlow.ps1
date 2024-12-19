<#
.SYNOPSIS
Invokes the OAuth2 client credentials flow.

.DESCRIPTION
This function will invoke the OAuth2 client credentials flow and return an access token.
The client credentials flow is used to obtain an access token for a client service.
The client service must be registered in Azure Active Directory.

.PARAMETER ClientId
The client Id of the client service.

.PARAMETER Tenant
Specifies the tenant ID or name. If the name is provided, it will be resolved to the corresponding tenant ID (Entra ID tenants only).

.PARAMETER Scope
A space-separated list of scopes that you want the user to consent to.

.PARAMETER ClientSecret
The client secret of the client service. Must be provided as a secure string.

.PARAMETER TokenEndpoint
(Optional) Specifies the endpoint to request an access token. If not specified, the default value is "https://login.microsoftonline.com/{tenant}/oauth2/v2.0/token".

.NOTES
https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-client-creds-grant-flow

.EXAMPLE
PS C:\> Invoke-ClientCredentialsFlow -ClientId <clientId> -Tenant <tenantId> -Scope <scope> -ClientSecret <clientSecret>

This example shows how to invoke the client credentials flow using the function.
#>
function Invoke-ClientCredentialsFlow {
    param (
        [Parameter(Mandatory)]
        [string]$ClientId,

        [Parameter(Mandatory)]
        [string]$Tenant,

        [Parameter(Mandatory)]
        [string]$Scope,

        [Parameter(Mandatory)]
        [securestring]$ClientSecret,

        [string]$TokenEndpoint
    )

    Write-Verbose "Starting Client Credentials Flow"
    Write-Verbose "--------------------------------"

    $GrantType = "client_credentials"

    # Resolve tenant ID if a tenant name is provided
    if ($Tenant -notmatch "^[0-9a-fA-F-]{36}$") {
        $Tenant = Get-MsftTenantId -TenantName $Tenant
    }

    # Entra ID default, if no token endpoint has been provided
    if ([string]::IsNullOrEmpty($TokenEndpoint)) {
        $TokenEndpoint = "https://login.microsoftonline.com/$Tenant/oauth2/v2.0/token"
    }

    # Get an access token
    $accTokenParam = @{
        TokenUrl     = $TokenEndpoint
        ClientId     = $ClientId
        Scope        = $Scope
        GrantType    = $GrantType
        ClientSecret = $ClientSecret
    }

    $response = Get-AccessToken @accTokenParam
    return $response

   
}

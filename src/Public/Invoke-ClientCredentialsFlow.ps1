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

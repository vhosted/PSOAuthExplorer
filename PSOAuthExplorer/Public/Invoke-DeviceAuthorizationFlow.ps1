<#

.SYNOPSIS
Invokes the OAuth 2.0 Device Authorization Flow.

.DESCRIPTION
This function initiates the OAuth 2.0 Device Authorization Flow, which is typically used for devices with limited input capabilities. It interacts with an authorization server to obtain access tokens.

.PARAMETER ClientId
Specifies the client ID of the application.

.PARAMETER Tenant
Specifies the tenant ID or name. If the name is provided, it will be resolved to the corresponding tenant ID (Entra ID tenants only).

.PARAMETER Scope
A space-separated list of scopes that you want the user to consent to.

.PARAMETER DeviceCodeEndpoint
(Optional) Specifies the endpoint to request a device code. If not specified, the default value is "https://login.microsoftonline.com/{tenant}/oauth2/v2.0/devicecode".

.PARAMETER TokenEndpoint
(Optional) Specifies the endpoint to request an access token. If not specified, the default value is "https://login.microsoftonline.com/{tenant}/oauth2/v2.0/token".

.NOTES
https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-device-code

.EXAMPLE
Invoke-DeviceAuthorizationFlow -ClientId "your-client-id" -Tenant "your-tenant-id" -Scope "openid profile email"

This example demonstrates how to initiate the device authorization flow using the specified client ID, tenant ID, and scopes.

.EXAMPLE
Invoke-DeviceAuthorizationFlow -ClientId "your-client-id" -Tenant "your-tenant-name" -Scope "openid profile email" -DeviceCodeEndpoint "https://custom-endpoint/devicecode" -TokenEndpoint "https://custom-endpoint/token"

This example demonstrates how to use custom endpoints for obtaining the device code and access token.

#>

function Invoke-DeviceAuthorizationFlow {
    param (
        [Parameter(Mandatory)]
        [string]$ClientId,

        [Parameter(Mandatory)]
        [string]$Tenant,

        [Parameter(Mandatory)]
        [string]$Scope,

        [string]$DeviceCodeEndpoint,

        [string]$TokenEndpoint
    )

    $GrantType = "urn:ietf:params:oauth:grant-type:device_code"

    # Resolve tenant ID if a tenant name is provided
    if ($Tenant -notmatch "^[0-9a-fA-F-]{36}$") {
        $Tenant = Get-MsftTenantId -TenantName $Tenant
    }

    # Entra ID default, if no device code endpoint has been provided
    if ([string]::IsNullOrEmpty($DeviceCodeEndpoint)) {
        $DeviceCodeEndpoint = "https://login.microsoftonline.com/$Tenant/oauth2/v2.0/devicecode"
    }

    # Entra ID default, if no token endpoint has been provided
    if ([string]::IsNullOrEmpty($TokenEndpoint)) {
        $TokenEndpoint = "https://login.microsoftonline.com/$Tenant/oauth2/v2.0/token"
    }

    $ContentType = "application/x-www-form-urlencoded"
    $authRequestBody = @{
        client_id = $ClientId
        scope     = $Scope
    }

    try {
        $authResponse = Invoke-RestMethod -Method Post -Uri $DeviceCodeEndpoint -ContentType $ContentType -Body $authRequestBody
    }
    catch {
        <#Do this if a terminating exception happens#>
    }

    if ($null -ne $authResponse) {
        $verificationUri = $authResponse.verification_uri
        $deviceCode = $authResponse.device_code
        $expiresIn = $authResponse.expires_in
        $pollingInterval = $authResponse.interval

        $ExpirationTime = (Get-Date).AddSeconds($expiresIn)

        Write-Host $authResponse.message -ForegroundColor Green
        Start-Process $verificationUri

        $accTokenParam = @{
            TokenUrl   = $TokenEndpoint
            ClientId   = $ClientId
            GrantType  = $GrantType
            DeviceCode = $deviceCode
        }

        while ($null -eq $tokenResponse -and (Get-Date) -lt $ExpirationTime) {
            Start-Sleep -Seconds $pollingInterval
            try {
                $tokenResponse = Get-AccessToken @accTokenParam -ErrorAction Stop
            }
            catch {
                $errorCategory = ($_.errordetails.message | convertfrom-json).error

                switch ($errorCategory) {
                    "authorization_pending" {
                        Write-Host -ForegroundColor Green "Waiting for authorization..."
                    }
                    "invalid_client" {
                        throw "Invalid client: Most likely your application is configured as confidential client."
                    }
                    Default {}
                }
            }
        }

        return $tokenResponse
    }
}

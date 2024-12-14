<#
.SYNOPSIS
Gets an access token using the authorization code flow.

.DESCRIPTION
This function redeems an authorization code for an access token.

.PARAMETER TokenUrl
The token endpoint URL.

.PARAMETER ClientId
The client ID of the application.

.PARAMETER ClientSecret
The client secret of the application. Must be provided as a secure string.

.PARAMETER RedirectUri
The redirect URI provided in the authorization request.

.PARAMETER Scope
A space-separated list of scopes that you want the user to consent to.

.PARAMETER GrantType
The grant type of the token request. The following values are supported: "authorization_code", "client_credentials", "refresh_token", "urn:ietf:params:oauth:grant-type:device_code", "password".

.PARAMETER AuthCode
The authorization code provided by the authorization server.

.PARAMETER CodeVerifier
The code verifier used to generate the code challenge.

.NOTES
https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-auth-code-flow#redeem-a-code-for-an-access-token

.EXAMPLE
Get-AccessToken -TokenUrl $tokenUrl -ClientId $clientId -ClientSecret $clientSecret -RedirectUri $redirectUri -Scope $scope -AuthCode $authCode

.EXAMPLE
Get-AccessToken -TokenUrl $tokenUrl -ClientId $clientId -ClientSecret $clientSecret -GrantType "client_credentials" -Scope $scope

.EXAMPLE
Get-AccessToken -TokenUrl $tokenUrl -ClientId $clientId -ClientSecret $clientSecret -GrantType "refresh_token" -Scope $scope -RefreshToken $refreshToken
#>
function Get-AccessToken {
    param (
        [cmdletbinding()]
        [Parameter(Mandatory)]
        [string]$TokenUrl,

        [Parameter(Mandatory)]
        [string]$ClientId,

        [Parameter(Mandatory)]
        [Validateset("authorization_code", "client_credentials", "refresh_token", "urn:ietf:params:oauth:grant-type:device_code", "password")]
        [string]$GrantType,

        [string]$RedirectUri,

        [securestring]$ClientSecret,

        [string]$AuthCode,

        [string]$Scope,
        
        [string]$CodeVerifier,

        [string]$DeviceCode
        
        
    )

    $ContentType = "application/x-www-form-urlencoded"
    $tokenRequestBody = @{
        client_id  = $ClientId
        grant_type = $GrantType
    }

    switch ($GrantType) {
        "authorization_code" {
            $tokenRequestBody.Add("code", $AuthCode)
            $tokenRequestBody.Add("redirect_uri", $RedirectUri)
            $tokenRequestBody.Add("scope", $Scope)

            if ($CodeVerifier) {
                $tokenRequestBody.Add("code_verifier", $CodeVerifier)
            }

            # Confidential Client
            if ($ClientSecret) {
                $tokenRequestBody.Add("client_secret", (ConvertFrom-SecureString $ClientSecret -AsPlainText))
            }
        }
        "client_credentials" {
            $tokenRequestBody.Add("client_secret", (ConvertFrom-SecureString $ClientSecret -AsPlainText))
            $tokenRequestBody.Add("scope", $Scope)
        }
        "refresh_token" {  }
        "urn:ietf:params:oauth:grant-type:device_code" {
            $tokenRequestBody.Add("device_code", $DeviceCode)
        }
        "password" {  }
        Default {}
    }

    Write-Verbose ($tokenRequestBody | Out-String)

    $response = Invoke-RestMethod -Method Post -Uri $TokenUrl -ContentType $ContentType -Body $tokenRequestBody
    return $response
}

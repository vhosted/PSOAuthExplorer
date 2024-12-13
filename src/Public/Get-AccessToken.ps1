# https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-auth-code-flow#redeem-a-code-for-an-access-token
function Get-AccessToken {
    param (
        [Parameter(Mandatory)]
        [string]$TokenUrl,
        [Parameter(Mandatory)]
        [string]$ClientId,
        [Parameter(Mandatory)]
        [string]$RedirectUri,
        [Parameter(Mandatory)]
        [Validateset("authorization_code", "client_credentials", "refresh_token", "urn:ietf:params:oauth:grant-type:device_code", "password")]
        [string]$GrantType,
        [securestring]$ClientSecret,
        [string]$AuthCode,
        [string]$Scope,
        [string]$CodeVerifier
        
        
    )

    $ContentType = "application/x-www-form-urlencoded"
    $tokenRequestBody = @{
        client_id    = $ClientId
        redirect_uri = $RedirectUri
    }

    switch ($GrantType) {
        "authorization_code" {
            $tokenRequestBody.Add("grant_type", $GrantType)
            $tokenRequestBody.Add("code", $AuthCode)
            
            if ($Scope) {
                $tokenRequestBody.Add("scope", $Scope)
            }

            if ($CodeVerifier) {
                $tokenRequestBody.Add("code_verifier", $CodeVerifier)
            }

            if ($ClientSecret) {
                # Confidential Client
                $tokenRequestBody.Add("client_secret", (ConvertFrom-SecureString $ClientSecret -AsPlainText))
            }
        }
        "client_credentials" {  }
        "refresh_token" {  }
        "urn:ietf:params:oauth:grant-type:device_code" {  }
        "password" {  }
        Default {}
    }

    $response = Invoke-RestMethod -Method Post -Uri $TokenUrl -ContentType $ContentType -Body $tokenRequestBody
    return $response
}

# https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-auth-code-flow#redeem-a-code-for-an-access-token
function Get-AccessToken {
    param (
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
        
        [string]$CodeVerifier
        
        
    )

    $ContentType = "application/x-www-form-urlencoded"
    $tokenRequestBody = @{
        client_id  = $ClientId
        scope      = $Scope
        grant_type = $GrantType
    }

    switch ($GrantType) {
        "authorization_code" {
            $tokenRequestBody.Add("code", $AuthCode)
            $tokenRequestBody.Add("redirect_uri", $RedirectUri)

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
        }
        "refresh_token" {  }
        "urn:ietf:params:oauth:grant-type:device_code" {  }
        "password" {  }
        Default {}
    }

    #Write-Verbose ($tokenRequestBody | Out-String)

    $response = Invoke-RestMethod -Method Post -Uri $TokenUrl -ContentType $ContentType -Body $tokenRequestBody
    return $response
}

function Get-AccessToken {
    param (
        [string]$ClientId,
        [string]$ClientSecret,
        [string]$AuthCode,
        [string]$RedirectUri,
        [string]$TokenUrl
    )

    $tokenRequestBody = @{
        client_id     = $ClientId
        client_secret = $ClientSecret
        code          = $AuthCode
        redirect_uri  = $RedirectUri
        grant_type    = "authorization_code"
    }

    $response = Invoke-RestMethod -Method Post -Uri $TokenUrl -ContentType "application/x-www-form-urlencoded" -Body $tokenRequestBody
    return $response
}

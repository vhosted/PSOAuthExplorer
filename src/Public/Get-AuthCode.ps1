function Get-AuthCode {
    param (
        [string]$ClientId,
        [string]$RedirectUri,
        [string]$Scope,
        [string]$AuthUrl
    )

    $encodedClientId = Encode-Url -Value $ClientId
    $encodedRedirectUri = Encode-Url -Value $RedirectUri
    $encodedScope = Encode-Url -Value $Scope

    $authRequestUrl = "$AuthUrl?client_id=$encodedClientId&response_type=code&redirect_uri=$encodedRedirectUri&scope=$encodedScope"
    Start-Process $authRequestUrl
}

function ConvertFrom-Jwt {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Token
    )
    
    if (!$token.Contains(".") -or !$token.StartsWith("eyJ")) {
        Write-Error "Invalid token" -ErrorAction Stop
    }

    $splitToken = $token.Split(".")

    $decodedJwt = @()

    foreach ($part in $splitToken) {
        $decodedJwt += ConvertFrom-Base64Url -Base64UrlSafeString $part
    }

    return [PSCustomObject]@{
        Header  = $decodedJwt[0] | ConvertFrom-Json
        Payload = $decodedJwt[1] | ConvertFrom-Json
    }
}

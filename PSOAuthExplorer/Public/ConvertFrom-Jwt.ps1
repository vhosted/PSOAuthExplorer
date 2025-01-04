function ConvertFrom-Jwt {
    <#
    .SYNOPSIS
        Converts a JSON Web Token (JWT) into a readable object.

    .DESCRIPTION
        This function takes a JWT string as input and decodes it into a readable object. 
        It can be used to inspect the contents of a JWT for debugging or informational purposes.

    .PARAMETER Jwt
        The JWT string that needs to be decoded.

    .EXAMPLE
        PS C:\> ConvertFrom-Jwt -Jwt "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"
        This command decodes the provided JWT string and returns its contents as a readable object.

    .INPUTS
        [string] The JWT string to be decoded.

    .OUTPUTS
        [PSCustomObject] The decoded contents of the JWT.
    #>
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

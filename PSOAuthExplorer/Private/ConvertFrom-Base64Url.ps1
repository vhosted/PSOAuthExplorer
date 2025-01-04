function ConvertFrom-Base64Url {
    <#
    .SYNOPSIS
        Converts a Base64 URL safe string to a decoded string.

    .DESCRIPTION
        This function takes a Base64 URL safe string, replaces URL safe characters with Base64 characters, 
        handles padding, and decodes it to a UTF-8 string.

    .PARAMETER Base64UrlSafeString
        The Base64 URL safe string to be decoded.

    .EXAMPLE
        PS> ConvertFrom-Base64Url -Base64UrlSafeString "SGVsbG8td29ybGQ_"
        Hello-world

    .INPUTS
        [string] The Base64 URL safe string to be decoded.

    .OUTPUTS
        [string] The decoded string.
    #>
    [cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Base64UrlSafeString
    )

    # replace - and _ with + and /
    $base64 = $Base64UrlSafeString.Replace('-', '+').Replace('_', '/')

    # handle padding
    $padding = $base64.Length % 4
    if ($padding -eq 2) {
        $base64 += "=="
    }
    elseif ($padding -eq 3) {
        $base64 += "="
    }

    # decode the base64 string
    $bytes = [Convert]::FromBase64String($base64)
    $decodedString = [System.Text.Encoding]::UTF8.GetString($bytes)

    return $decodedString
}
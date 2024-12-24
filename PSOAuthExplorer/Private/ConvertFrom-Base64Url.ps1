function ConvertFrom-Base64Url {
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
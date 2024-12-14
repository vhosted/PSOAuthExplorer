<#
.SYNOPSIS
Generates a random URL-safe string of the given length for use as a
code challenge.

.DESCRIPTION
The string is generated according to the rules outlined in RFC 7636
section 4.1. The string is URL-safe and may contain the following
characters: A-Z, a-z, 0-9, and the special characters -._~.

.PARAMETER Length
The length of the code challenge string to generate. Defaults to 43.

.PARAMETER Method
The PKCE method to use. Currently, only "S256" is supported, which
uses the SHA-256 hash function to generate the code verifier.

.NOTES
https://datatracker.ietf.org/doc/html/rfc7636#section-4.1

.EXAMPLE
New-PKCEChallenge -Length 32 -Method "S256"
.OUTPUTS
A string of the given length suitable for use as a code challenge.
#>
function New-PKCEChallenge {
    [CmdletBinding()]
    param (
        [int]$Length = 43,
        [ValidateSet("S256")]
        [string]$Method = "S256"
    )

    $unreservedChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~"

    # Generate a random string based on unreserved characters and length
    $codeVerifier = -join ((1..$Length) | ForEach-Object { $unreservedChars[(Get-Random -Minimum 0 -Maximum ($unreservedChars.Length - 1))] })
    Write-Verbose "PKCE code_verifier:`t$codeVerifier"

    # Convert the code verifier to bytes
    $codeVerifierBytes = [System.Text.Encoding]::ASCII.GetBytes($codeVerifier)

    # Create a SHA256 hash
    $sha256 = [System.Security.Cryptography.SHA256]::Create()
    $hashBytes = $sha256.ComputeHash($codeVerifierBytes)

    # Convert the hash to a base64 URL-safe string
    $codeChallenge = [System.Convert]::ToBase64String($hashBytes)
    $codeChallenge = $codeChallenge.Replace('+', '-').Replace('/', '_').Replace('=', '')
    Write-Verbose "PKCE code_challenge:`t$codeChallenge"
    
    return @{
        CodeVerifier        = $codeVerifier
        CodeChallenge       = $codeChallenge
        CodeChallengeMethod = $Method
    }
}

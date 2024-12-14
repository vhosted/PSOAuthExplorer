<#
.SYNOPSIS
Gets an authorization code using the authorization code flow.

.DESCRIPTION
This function redirects the user to the authorization URL and waits for the authorization code to be provided.

.PARAMETER AuthUrl
The authorization endpoint URL.

.PARAMETER ClientId
The client ID of the application.

.PARAMETER RedirectUri
The redirect URI provided in the authorization request.

.PARAMETER Scope
A space-separated list of scopes that you want the user to consent to.

.PARAMETER ResponseType
The response type of the authorization request. Currently only "code" is supported, which is the default value. Hybrid flows are not supported.

.PARAMETER ResponseMode
The response mode of the authorization request. Currently only "query" is supported, which is the default value.

.PARAMETER State
(Optional) The state parameter of the authorization request.

.PARAMETER Prompt
The prompt parameter of the authorization request. The default value is "select_account". Other valid values are "none", "login", and "consent".

.PARAMETER LoginHint
(Optional) The login_hint parameter of the authorization request.

.PARAMETER CodeChallenge
The code_challenge parameter of the authorization request.

.PARAMETER CodeChallengeMethod
The code_challenge_method parameter of the authorization request. Currently only "S256" is supported.

.NOTES
https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-auth-code-flow#request-an-authorization-code

.EXAMPLE
Get-AuthorizationCode -AuthUrl $authUrl -ClientId $clientId -RedirectUri $redirectUri -Scope $scope
#>
function Get-AuthorizationCode {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$AuthUrl,
        [Parameter(Mandatory)]
        [string]$ClientId,
        [Parameter(Mandatory)]
        [string]$RedirectUri,
        [Parameter(Mandatory)]
        [string]$Scope,
        [string]$ResponseType = "code",
        [string]$ResponseMode = "query",
        [string]$State,
        [string]$Prompt = "select_account",
        [string]$LoginHint,
        [string]$CodeChallenge,
        [string]$CodeChallengeMethod
        
    )

    $encodedClientId = ConvertTo-URL $ClientId
    $encodedRedirectUri = ConvertTo-URL $RedirectUri
    $encodedScope = ConvertTo-URL $Scope

    $authRequestUrl = "$($AuthUrl)?client_id=$encodedClientId&response_type=$ResponseType&prompt=$Prompt&redirect_uri=$encodedRedirectUri&scope=$encodedScope"
    
    if ([string]::IsNullOrEmpty($CodeChallenge) -eq $false) {
        
        $authRequestUrl += "&code_challenge=$CodeChallenge&code_challenge_method=$CodeChallengeMethod"
    }

    if ([string]::IsNullOrEmpty($State) -eq $false) {
        $State = ConvertTo-URL $State
        $authRequestUrl += "&state=$State"
    }

    if ([string]::IsNullOrEmpty($LoginHint) -eq $false) {
        $LoginHint = ConvertTo-URL $LoginHint
        $authRequestUrl += "&login_hint=$LoginHint"
    }

    Write-Verbose "Auth Request URL:`t$authRequestUrl"
    Write-Verbose "Starting browser for user authentication..."
    Start-Process $authRequestUrl
}

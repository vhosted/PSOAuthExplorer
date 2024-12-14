#https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-auth-code-flow#request-an-authorization-code
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

    Write-Verbose "Auth Request URL:`t$authRequestUrl"
    Write-Verbose "Starting browser for user authentication..."
    Start-Process $authRequestUrl
}

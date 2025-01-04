<#
    .SYNOPSIS
    Invokes the OAuth2 authorization code flow.

    .DESCRIPTION
    This function will invoke the OAuth2 authorization code flow and return an access token.
    The authorization code flow is used to obtain an access token for a client service.
    The client service must be registered in Azure Active Directory.

    .PARAMETER ClientId
    The client Id of the client service.

    .PARAMETER Tenant
    Specifies the tenant ID or name. If the name is provided, it will be resolved to the corresponding tenant ID (Entra ID tenants only).

    .PARAMETER RedirectUri
    The redirect URI of the client service.

    .PARAMETER Scope
    A space-separated list of scopes that you want the user to consent to.

    .PARAMETER ClientSecret
    (Optional) Confidential clients only. The client secret of the client service. Must be provided as a secure string.

    .PARAMETER AuthorizationEndpoint
    (Optional) Specifies the endpoint to request authorization. If not specified, the default value is "https://login.microsoftonline.com/{tenant}/oauth2/v2.0/authorize".

    .PARAMETER TokenEndpoint
    (Optional) Specifies the endpoint to request an access token. If not specified, the default value is "https://login.microsoftonline.com/{tenant}/oauth2/v2.0/token".

    .PARAMETER PKCE
    (Optional) If specified, the function will use PKCE (Proof Key for Code Exchange) to protect the authorization code.

    .NOTES
    https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-auth-code-flow

    .EXAMPLE
    PS C:\> Invoke-AuthorizationCodeFlow -ClientId "38964a68-dd39-472e-8d26-b603ef27f1f3" -Tenant "a9cb93b5-628d-4d91-9167-245ad1b55a52" -RedirectUri "http://localhost:8080/" -Scope "openid profile email User.Read" -ClientSecret (ConvertTo-SecureString "secret_goes_here" -AsPlainText)

    This example shows how to invoke the authorization code flow using the function.

    .LINK
    https://learn.microsoft.com/en-us/entra/identity/protocols/oauth2-authorization-code-flow
    #>
function Invoke-AuthorizationCodeFlow {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$ClientId,

        [Parameter(Mandatory)]
        [string]$Tenant,

        [Parameter(Mandatory)]
        [string]$RedirectUri,

        [Parameter(Mandatory)]
        [string]$Scope,

        [securestring]$ClientSecret,

        [string]$AuthorizationEndpoint,

        [string]$TokenEndpoint,

        [switch]$PKCE
    )
    Write-Verbose "Starting Authorization Code Flow"
    Write-Verbose "--------------------------------"

    $GrantType = "authorization_code"

    # Resolve tenant ID if a tenant name is provided
    if ($Tenant -notmatch "^[0-9a-fA-F-]{36}$") {
        $Tenant = Get-MsftTenantId -TenantName $Tenant
    }

    # Entra ID default, if no authorization endpoint has been provided
    if ([string]::IsNullOrEmpty($AuthorizationEndpoint)) {
        $AuthorizationEndpoint = "https://login.microsoftonline.com/$Tenant/oauth2/v2.0/authorize"
    }

    # Entra ID default, if no token endpoint has been provided
    if ([string]::IsNullOrEmpty($TokenEndpoint)) {
        $TokenEndpoint = "https://login.microsoftonline.com/$Tenant/oauth2/v2.0/token"
    }

    $authReqParam = @{
        AuthUrl     = $AuthorizationEndpoint
        ClientId    = $ClientId
        RedirectUri = $RedirectUri
        Scope       = $Scope
    }

    if ($PKCE) {
        Write-Verbose "PKCE:`t`t`tEnabled"
        $PKCEChallenge = New-PKCEChallenge
        $authReqParam.Add("CodeChallenge", $PKCEChallenge.CodeChallenge)
        $authReqParam.Add("CodeChallengeMethod", $PKCEChallenge.CodeChallengeMethod)
    }
    else {
        Write-Verbose "PKCE:`t`t`tDisabled"
    }

    $listenerPort = $RedirectUri.Split(":")[-1].Replace("/", "")

    # Startup HTTP listener as a job to catch authorization code, stops after a default timeout of 60 seconds
    $HttpListenerDefinition = Get-Command "Start-HttpListener"
    $HttpListenerFunction = "function $($HttpListenerDefinition.Name) { $($HttpListenerDefinition.Definition) }"
    Write-Verbose "Starting HTTP listener on port tcp/$listenerPort"
    $job = Start-Job -Name "StartupHttpListener" -ScriptBlock {
        param ($RedirectUri, $HttpListenerFunction)
        Invoke-Expression $HttpListenerFunction
        Start-HttpListener -Prefix $RedirectUri -Verbose
    } -ArgumentList $RedirectUri, $HttpListenerFunction

    Get-AuthorizationCode @authReqParam

    # Wait for the job to complete and get the authorization code
    $jobResult = Receive-Job -Job $job -Wait -AutoRemoveJob
    $authCode = $jobResult

    if ([string]::IsNullOrEmpty($authCode)) {
        Write-Error "Authorization code not found. Check your configuration and parameters."
        Exit 1
    }

    Write-Verbose "Auth Code received:`t$authCode"

    # Get an access token
    $accTokenParam = @{
        TokenUrl    = $TokenEndpoint
        ClientId    = $ClientId
        RedirectUri = $RedirectUri
        Scope       = $Scope
        GrantType   = $GrantType
        AuthCode    = $authCode
    }

    # Confidential Client
    if ($ClientSecret -ne $null) {
        $accTokenParam.Add("ClientSecret", $ClientSecret)
    }

    if ($PKCE) {
        $accTokenParam.Add("CodeVerifier", $PKCEChallenge.CodeVerifier)
    }

    $response = Get-AccessToken @accTokenParam
    return $response
}

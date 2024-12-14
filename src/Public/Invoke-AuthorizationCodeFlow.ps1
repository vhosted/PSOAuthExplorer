# example:
# Invoke-AuthorizationCodeFlow -ClientId "38964a68-dd39-472e-8d26-b603ef27f1f3" -Tenant "a9cb93b5-628d-4d91-9167-245ad1b55a52" -RedirectUri "http://localhost:8080/" -Scope "openid profile email User.Read" -ClientSecret (ConvertTo-SecureString "secret_goes_here" -AsPlainText) -PKCE -Verbose
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
    # Write-Verbose "Starting HTTP listener on port tcp/$listenerPort"
    $job = Start-Job -Name "StartupHttpListener" -ScriptBlock {
        param ($RedirectUri)
        # needed while testing
        $ModulePath = "C:\work\Git\PSOAuthExplorer\src\PSOAuthExplorer.psd1"
        if (Test-Path $ModulePath) { Import-Module $ModulePath }
        Start-HttpListener -Prefix $RedirectUri -Verbose
    } -ArgumentList $RedirectUri

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

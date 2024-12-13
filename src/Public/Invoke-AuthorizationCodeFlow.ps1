function Invoke-AuthorizationCodeFlow {
    [CmdletBinding()]
    param (
        [string]$ClientId,
        [securestring]$ClientSecret,
        [string]$Tenant,
        [string]$RedirectUri = "http://localhost:8080/",
        [string]$Scope,
        [string]$AuthorizationEndpoint,
        [string]$TokenEndpoint
    )

    # Resolve tenant ID if a tenant name is provided
    if ($Tenant -notmatch "^[0-9a-fA-F-]{36}$") {
        $Tenant = Get-MsftTenantId -TenantName $Tenant
    }

    # Entra ID default, if no authorization endpoint has been provided
    if ("" -eq $AuthorizationEndpoint) {
        $AuthorizationEndpoint = "https://login.microsoftonline.com/$Tenant/oauth2/v2.0/authorize"
    }

    # Entra ID default, if no token endpoint has been provided
    if ("" -eq $TokenEndpoint) {
        $TokenEndpoint = "https://login.microsoftonline.com/$Tenant/oauth2/v2.0/token"
    }

    $listenerPort = $RedirectUri.Split(":")[-1].Replace("/", "")

    # Startup HTTP listener as a job to catch authorization code, stops after a default timeout of 60 seconds
    Write-Verbose "Starting HTTP listener on port tcp/$listenerPort"
    $job = Start-Job -Name "StartupHttpListener" -ScriptBlock {
        param ($RedirectUri)
        # needed while testing
        $ModulePath = "C:\work\Git\PSOAuthExplorer\src\PSOAuthExplorer.psd1"
        if (Test-Path $ModulePath) { Import-Module $ModulePath }
        Start-HttpListener -Prefix $RedirectUri -Verbose
    } -ArgumentList $RedirectUri

    Get-AuthorizationCode -ClientId $ClientId -RedirectUri $RedirectUri -Scope $Scope -AuthUrl $AuthorizationEndpoint

    # Wait for the job to complete and get the authorization code
    $jobResult = Receive-Job -Job $job -Wait -AutoRemoveJob
    $authCode = $jobResult

    if ($null -eq $authCode -or "" -eq $authCode) {
        Write-Error "Authorization code not found. Check your configuration and parameters."
        Exit 1
    }

    Write-Verbose "Authorization Code: $authCode"

    # Get an access token
    $parameters = @{
        TokenUrl     = $TokenEndpoint
        ClientId     = $ClientId
        RedirectUri  = $RedirectUri
        Scope        = $Scope
        GrantType    = "authorization_code"
        ClientSecret = $ClientSecret
        AuthCode     = $authCode
    }

    $response = Get-AccessToken @parameters
    return $response
}

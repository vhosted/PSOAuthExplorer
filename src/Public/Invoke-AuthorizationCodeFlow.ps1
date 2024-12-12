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
        $Tenant = Get-TenantId -TenantName $Tenant
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

    # URL encoding
    $encodedRedirectUri = ConvertTo-URL $RedirectUri
    $encodedScope = ConvertTo-URL $Scope
    Write-Verbose $AuthorizationEndpoint
    # Construct URL for the authentication request
    $authRequestUrl = "$($AuthorizationEndpoint)?client_id=$ClientId&response_type=code&redirect_uri=$encodedRedirectUri&scope=$encodedScope"

    # Startup HTTP listener as a job to catch authorization code, stops after a default timeout of 60 seconds
    Write-Verbose "Starting HTTP listener on port tcp/$listenerPort"
    $job = Start-Job -Name "StartupHttpListener" -ScriptBlock {
        param ($RedirectUri)
        # needed while testing
        $ModulePath = "C:\work\Git\PSOAuthExplorer\src\PSOAuthExplorer.psd1"
        if (Test-Path $ModulePath) { Import-Module $ModulePath }
        Start-HttpListener -Prefix $RedirectUri -Verbose
    } -ArgumentList $RedirectUri
    
    Write-Verbose "Open browser for user authentication"
    Start-Process $authRequestUrl

    # Wait for the job to complete and get the authorization code
    $jobResult = Receive-Job -Job $job -Wait -AutoRemoveJob
    $authCode = $jobResult

    Write-Verbose "Authorization Code: $authCode"
}

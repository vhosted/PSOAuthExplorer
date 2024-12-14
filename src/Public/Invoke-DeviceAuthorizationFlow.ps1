function Invoke-DeviceAuthorizationFlow {
    param (
        [Parameter(Mandatory)]
        [string]$ClientId,

        [Parameter(Mandatory)]
        [string]$Tenant,

        [Parameter(Mandatory)]
        [string]$Scope,

        [string]$DeviceCodeEndpoint,

        [string]$TokenEndpoint
    )

    $GrantType = "urn:ietf:params:oauth:grant-type:device_code"

    # Resolve tenant ID if a tenant name is provided
    if ($Tenant -notmatch "^[0-9a-fA-F-]{36}$") {
        $Tenant = Get-MsftTenantId -TenantName $Tenant
    }

    # Entra ID default, if no device code endpoint has been provided
    if ([string]::IsNullOrEmpty($DeviceCodeEndpoint)) {
        $DeviceCodeEndpoint = "https://login.microsoftonline.com/$Tenant/oauth2/v2.0/devicecode"
    }

    # Entra ID default, if no token endpoint has been provided
    if ([string]::IsNullOrEmpty($TokenEndpoint)) {
        $TokenEndpoint = "https://login.microsoftonline.com/$Tenant/oauth2/v2.0/token"
    }

    $ContentType = "application/x-www-form-urlencoded"
    $authRequestBody = @{
        client_id = $ClientId
        scope     = $Scope
    }

    try {
        $authResponse = Invoke-RestMethod -Method Post -Uri $DeviceCodeEndpoint -ContentType $ContentType -Body $authRequestBody
        
    }
    catch {
        <#Do this if a terminating exception happens#>
    }

    if ($null -ne $authResponse) {
        $verificationUri = $authResponse.verification_uri
        $userCode = $authResponse.user_code
        $deviceCode = $authResponse.device_code
        $expiresIn = $authResponse.expires_in
        $pollingInterval = $authResponse.interval

        $ExpirationTime = (Get-Date).AddSeconds($expiresIn)

        Write-Host $authResponse.message -ForegroundColor Green
        Start-Process $verificationUri

        $accTokenParam = @{
            TokenUrl   = $TokenEndpoint
            ClientId   = $ClientId
            GrantType  = $GrantType
            DeviceCode = $deviceCode
        }

        while ($null -eq $tokenResponse -and (Get-Date) -lt $ExpirationTime) {
            Start-Sleep -Seconds $pollingInterval
            try {
                $tokenResponse = Get-AccessToken @accTokenParam -ErrorAction Stop
            }
            catch {
                $errorCategory = ($_.errordetails.message | convertfrom-json).error

                switch ($errorCategory) {
                    "authorization_pending" {
                        Write-Host -ForegroundColor Green "Waiting for authorization..."
                    }
                    "invalid_client" {
                        throw "Invalid client: Most likely your application is configured as confidential client."
                    }
                    Default {}
                }
            }
        }

        return $tokenResponse
    }
}

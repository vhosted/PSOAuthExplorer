<#
.SYNOPSIS
Resolves the tenant ID from a tenant name.

.DESCRIPTION
This cmdlet resolves the tenant ID of an Azure AD tenant from a tenant name.

.PARAMETER TenantName
The tenant name to resolve.

.EXAMPLE
PS C:\> Get-MsftTenantId -TenantName "example.com"
#>
function Get-MsftTenantId {
    param (
        [string]$TenantName
    )

    $metadataUrl = "https://login.microsoftonline.com/$TenantName/.well-known/openid-configuration"
    try {
        $response = Invoke-RestMethod -Uri $metadataUrl -Method Get
        $tenantId = ($response.issuer | Select-String -Pattern "[0-9a-fA-F-]{36}").Matches.Value
        return $tenantId
    }
    catch {
        Write-Error "Failed to resolve tenant ID from tenant name: $_"
        return $null
    }
}

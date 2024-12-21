[![Latest Release](https://img.shields.io/github/v/release/vhosted/PSOAuthExplorer)](https://github.com/vhosted/PSOAuthExplorer/releases/latest)
[![test build and publish PowerShell module](https://github.com/vhosted/PSOAuthExplorer/actions/workflows/build.yml/badge.svg)](https://github.com/vhosted/PSOAuthExplorer/actions/workflows/build.yml)
# PSOAuthExplorer

**PSOAuthExplorer** is a PowerShell module created for exploring, testing, and learning OAuth2 and OpenID Connect (OIDC) flows. Heavily focused on Entra ID, other IdPs have not been tested yet.

## Features

- **Authorization Code Flow**: Learn and test the OAuth2 authorization code flow, with PKCE support.
- **Client Credentials Flow**: Learn and test the Oauth2 client credentials flow.
- **Device Authorization Flow**: Learn and test the OAuth2 Device Authorization Flow.

## Upcoming Features
- **Information/Help pages for OAUTH flows**: Detailed information and examples for each flow.
- **Verbose output**: Detailed output to see exactly how each step in the flows is happening.
- **Import/Export flow configs**: Save and load configurations for different flows.
- **Manifest config generator**: Generate a Entra ID manifest from a flow config (and vice versa).
- **Token Verification**: Verify if a token is valid.

## Installation

### Install from PowerShell Gallery

```powershell
Install-Module PSOAuthExplorer
```
### Download latest release and import manually
[![Latest Release](https://img.shields.io/github/v/release/vhosted/PSOAuthExplorer)](https://github.com/vhosted/PSOAuthExplorer/releases/latest)
### Clone repository and import manually

```powershell
git clone https://github.com/vhosted/PSOAuthExplorer.git
Import-Module ./PSOAuthExplorer/PSOAuthExplorer.psm1
```
## Usage

> [!IMPORTANT]  
> It is expected, that the applicable scopes for the flow are already granted by the user or an admin.

### OpenID Configuration
For Entra ID tenants, visit https://login.microsoftonline.com/{tenantId}/v2.0/.well-known/openid-configuration to get information about the endpoints among other information.

### Authorization Code Flow
The first example below shows how to invoke the authorization code flow for a public client (no secret or certificate) using PKCE. The requested OIDC scopes are "openid", "profile", and "email". The function starts a http listener on port 8080 and to capture the authorization code, which is then redeemed for an access token. Returns the response of the token endpoint, containing an id token and access token. If `-AuthorizationEndpoint` and `-TokenEndpoint` are not provided, the default endpoints for Entra ID will be used, based on the tenantId provided with the `-Tenant` parameter.
```powershell
Invoke-AuthorizationCodeFlow -ClientId "{clientId}" -Tenant "{tenantId}" -RedirectUri "http://localhost:8080/" -Scope "openid profile email" -PKCE
```
The second example below shows how to invoke the authorization code flow for a confidential client using a client secret and PKCE. `-AuthorizationEndpoint` and `-TokenEndpoint` are optional, and if not provided, the default endpoints for Entra ID will be used, based on the tenantId provided with the `-Tenant` parameter.
```powershell
Invoke-AuthorizationCodeFlow -ClientId "{clientId}" -Tenant "{tenantId}" -RedirectUri "http://localhost:8080/" -Scope "openid profile email" -ClientSecret (ConvertTo-SecureString "{clientSecret}" -AsPlainText -Force) -AuthorizationEndpoint "{authEndpoint}" -TokenEndpoint "{tokenEndpoint}"
```
### Client Credentials Flow
This example shows how to invoke the client credentials flow (confidential client). The parameters `-ClientId`, `-Tenant`, `-ClientSecret`, and `-Scope` are required. The `-TokenEndpoint` is optional, and if not provided, the default endpoint for Entra ID will be used, based on the tenantId provided with the `-Tenant` parameter.
The value for the parameter `-Scope` should be the resource identifier suffixed with `.default`. All scopes included must be for a single resource.
```powershell
Invoke-ClientCredentialsFlow -ClientId "{clientId}" -Tenant "{tenantId}" -Scope "https://graph.microsoft.com/.default" -ClientSecret (ConvertTo-SecureString "{clientSecret}" -AsPlainText -Force)
```

### Device Authorization Flow
Device Authorization Flow is primarily intended for input-constrained devices like smart TVs and IoT devices. The flow is typically started on such a device and has the user visit a webpage on a more input friendly device and use a code to redeem an access token.
The example below shows how to invoke the device authorization flow using the default endpoints for Entra ID. The parameters `-ClientId`, `-Tenant`, and `-Scope` are required.
The application has to configured to allow public client flows (Entra ID manifest: `"isFallbackPublicClient": true`).
```powershell
Invoke-DeviceAuthorizationFlow -ClientId "{clientId}" -Tenant "{tenantId}" -Scope "openid email profile"
```
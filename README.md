# PSOAuthExplorer

**PSOAuthExplorer** is a PowerShell module designed for exploring, testing, and learning OAuth2 and OpenID Connect (OIDC) flows. It provides detailed, step-by-step guidance and verbose output to help users understand the intricacies of authentication and authorization processes.

## Features

- **Authorization Code Flow**: Learn and test the OAuth2 authorization code flow.
- **Client Credentials Flow**: Understand and implement the client credentials flow.
- **Verbose Output**: Detailed output to see exactly how each step in the flows is happening.
- **Helper Functions**: Utility functions to assist with common tasks like URL encoding.

## Installation

To install the module, clone the repository and import the module:

```powershell
git clone https://github.com/your-repo/PSOAuthExplorer.git
Import-Module ./PSOAuthExplorer/PSOAuthExplorer.psm1

<#
.SYNOPSIS
Converts a string to a URL-safe string using the UrlEncode method.

.DESCRIPTION
This function takes a string as an input and returns a URL-safe string using the UrlEncode method.

.PARAMETER Value
The string to be converted to a URL-safe string.

.EXAMPLE
PS C:\> ConvertTo-Url -Value "This is a Test!"

Output: This+is+a+Test%21

.LINK
https://learn.microsoft.com/en-us/dotnet/api/system.web.httputility.urlencode?view=netframework-4.8
#>
function ConvertTo-Url {
    param (
        [string]$Value
    )

    return [System.Web.HttpUtility]::UrlEncode($Value)
}

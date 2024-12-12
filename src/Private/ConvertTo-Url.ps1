function ConvertTo-Url {
    param (
        [string]$Value
    )

    return [System.Web.HttpUtility]::UrlEncode($Value)
}

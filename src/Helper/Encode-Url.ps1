function Encode-Url {
    param (
        [string]$Value
    )

    return [System.Web.HttpUtility]::UrlEncode($Value)
}

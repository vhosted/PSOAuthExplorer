function Start-HttpListener {
    param (
        [string]$Prefix
    )

    $httpListener = New-Object System.Net.HttpListener
    $httpListener.Prefixes.Add($Prefix)
    $httpListener.Start()

    while ($httpListener.IsListening) {
        $context = $httpListener.GetContext()
        $response = $context.Response
        $request = $context.Request

        $authCode = $request.QueryString["code"]

        if ($authCode) {
            $response.StatusCode = 200
            $response.ContentType = 'text/html'
            $response.OutputStream.Write([Text.Encoding]::UTF8.GetBytes("<html><body>Authorization code received: $authCode</body></html>"), 0, 50)
            $response.Close()
            $httpListener.Stop()
            return $authCode
        }
        else {
            $response.StatusCode = 400
            $response.ContentType = 'text/html'
            $response.OutputStream.Write([Text.Encoding]::UTF8.GetBytes("<html><body>Error: Authorization code not found</body></html>"), 0, 50)
            $response.Close()
        }
    }
}

# Define parameters
$tenantId = "a9cb93b5-628d-4d91-9167-245ad1b55a52"
$clientId = "38964a68-dd39-472e-8d26-b603ef27f1f3"
$clientSecret = "secrethere"
$redirectUri = "http://localhost:8080/"
$scope = "openid profile email"
$authUrl = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/authorize"
$tokenUrl = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"


# URL-encode the parameters
$encodedRedirectUri = [System.Web.HttpUtility]::UrlEncode($redirectUri)
$encodedScope = [System.Web.HttpUtility]::UrlEncode($scope)

# Construct the URL
$authRequestUrl = "$($authUrl)?client_id=$encodedClientId&response_type=code&redirect_uri=$encodedRedirectUri&scope=$encodedScope"

# Start the HTTP listener as a job
$job = Start-Job -ScriptBlock {
    $httpListener = New-Object System.Net.HttpListener
    $httpListener.Prefixes.Add("http://localhost:8080/")
    $httpListener.Start()

    while ($httpListener.IsListening) {
        $context = $httpListener.GetContext()
        $response = $context.Response
        $request = $context.Request

        # Extract the authorization code from the query string
        $authCode = $request.QueryString["code"]

        if ($authCode) {
            # Respond to the browser
            $response.StatusCode = 200
            $response.ContentType = 'text/html'
            $response.OutputStream.Write([Text.Encoding]::UTF8.GetBytes("<html><body>Authorization code received: $authCode</body></html>"), 0, 50)
            $response.Close()

            # Stop the listener
            $httpListener.Stop()
            return $authCode
        }
        else {
            # Respond with an error message if no code is found
            $response.StatusCode = 400
            $response.ContentType = 'text/html'
            $response.OutputStream.Write([Text.Encoding]::UTF8.GetBytes("<html><body>Error: Authorization code not found</body></html>"), 0, 50)
            $response.Close()
        }
    }
}

# Open browser for user authentication
Start-Process $authRequestUrl

# Wait for the job to complete and get the authorization code
$jobResult = Receive-Job -Job $job -Wait -AutoRemoveJob
$authCode = $jobResult

# Output the authorization code
Write-Output "Authorization Code: $authCode"






# Define parameters
#$authCode = "1.AU4AtZPLqY1ikU2RZyRa0bVaUmhKljg53S5HjSa2A-8n8fODAHNOAA.AgABBAIAAADW6jl31mB3T7ugrWTT8pFeAwDs_wUA9P8LpRl1aUoMuGTrUg5YqY2-c4wNk-Y0BKmAD_flVLL0evf1UdZcQlbwPT_Xx2vBokKUfhDnBTAg7l1Xhf9arpbfIvwCny8afH4_FnsR9eAlyEW8hmzAydQ8HD0N9h6JBRMxxX2_aXaXGQFbF-XeX-WxhLQI3hnL3CaeUCXssxyHFH1zlXsHNY0AXjSM0spj7WS0RCca0Zd_BxVfZnkEs1ZbmWZZ_V3D0a7I9z4R3MbdJIF0WLrgrENbEOMXi5bq06T6dPAZ4cM6p7KP2n9bOMBIss7RqoqZ7PBAjIn426q0ElI2rej5aXfb3c6njfrXI6wKbe0El6bJTusCxK5g-aUikGwTlZrmD1qUmsrQejk-tGW4adE7_5tsp0BX-hKqkPoXPcqZlZjeyCdL5dl2NSmSKpVVsEUpGu5FLWyUU2EntTwbrdgfLHZIU6Sp2SZSkcA6NcpnSuS_YqJEtZB-5qsI1A_MQYZXKQssLr4irbVgoQX0gjtBCYikXj2DK_DYZt7HjjKHzETeM252pWgyKCwmjmYTWNL0-guNCvi9juP6foRmOhVoyhKA8Qc6gJNifGZhgYQfXHD9HO7ETtKUpkyqHseM7JpeyX-5TmapKrvjrrs4A1W-2ScwPNhKsiOKl2E9UWsnMC7HjrP1byKesvb9OFwy9Eba90XuJo-FmeLGguTGjvPlf8H--ab2wb1-P4Ft"

# Prepare the token request
$tokenRequestBody = @{
    client_id     = $clientId
    client_secret = $clientSecret
    code          = $authCode
    redirect_uri  = $redirectUri
    grant_type    = "authorization_code"
}

# Send the token request
$response = Invoke-RestMethod -Method Post -Uri $tokenUrl -ContentType "application/x-www-form-urlencoded" -Body $tokenRequestBody
$accessToken = $response.access_token
$idToken = $response.id_token

# Output tokens
Write-Output "Access Token: $accessToken"
Write-Output "ID Token: $idToken"

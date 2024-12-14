function Draw-Rectangle {
    param (
        [string]$Label,
        [int]$Width = 20
    )
    $line = "+" + ("-" * ($Width - 2)) + "+"
    $padding = " " * (($Width - 2 - $Label.Length) / 2)
    $content = "|" + $padding + $Label + $padding + "|"
    return @($line, $content, $line)
}

function Draw-Arrow {
    param (
        [string]$Direction,
        [string]$Label = ""
    )
    switch ($Direction) {
        "right" { return "----> $Label" }
        "left" { return "<---- $Label" }
        "down" { return "| $Label" }
        "up" { return "| $Label" }
        default { return "" }
    }
}

$global:DiagramState = @()

function Add-ToDiagram {
    param (
        [string[]]$Lines
    )
    $global:DiagramState += $Lines
}

function Get-Diagram {
    return $global:DiagramState -join "`n"
}

function Draw-OAuthFlow {
    param (
        [switch]$Explain
    )

    # Clear the diagram state
    $global:DiagramState = @()

    # Draw the client rectangle
    $client = Draw-Rectangle -Label "Client"
    Add-ToDiagram -Lines $client

    # Draw the arrow to the authorization server
    $arrow1 = Draw-Arrow -Direction "right" -Label "(1) Authorization Request"
    Add-ToDiagram -Lines @($arrow1)

    # Draw the authorization server rectangle
    $authServer = Draw-Rectangle -Label "Authorization Server"
    Add-ToDiagram -Lines $authServer

    # Draw the arrow back to the client
    $arrow2 = Draw-Arrow -Direction "left" -Label "(2) Authorization Code"
    Add-ToDiagram -Lines @($arrow2)

    # Draw the arrow to the token endpoint
    $arrow3 = Draw-Arrow -Direction "right" -Label "(3) Token Request"
    Add-ToDiagram -Lines @($arrow3)

    # Draw the token endpoint rectangle
    $tokenEndpoint = Draw-Rectangle -Label "Token Endpoint"
    Add-ToDiagram -Lines $tokenEndpoint

    # Draw the arrow back to the client
    $arrow4 = Draw-Arrow -Direction "left" -Label "(4) Access Token"
    Add-ToDiagram -Lines @($arrow4)

    # Draw the arrow to the resource server
    $arrow5 = Draw-Arrow -Direction "right" -Label "(5) API Request"
    Add-ToDiagram -Lines @($arrow5)

    # Draw the resource server rectangle
    $resourceServer = Draw-Rectangle -Label "Resource Server"
    Add-ToDiagram -Lines $resourceServer

    # Draw the arrow back to the client
    $arrow6 = Draw-Arrow -Direction "left" -Label "(6) API Response"
    Add-ToDiagram -Lines @($arrow6)

    # Output the diagram
    $diagram = Get-Diagram
    Write-Output $diagram

    if ($Explain) {
        Write-Output "Explanation of Steps:"
        Write-Output "1. Authorization Request: The client requests authorization from the authorization server."
        Write-Output "2. Authorization Code: The authorization server returns an authorization code to the client."
        Write-Output "3. Token Request: The client requests an access token from the authorization server using the authorization code."
        Write-Output "4. Access Token: The authorization server returns an access token to the client."
        Write-Output "5. API Request: The client makes an API request to the resource server using the access token."
        Write-Output "6. API Response: The resource server returns the requested resource to the client."
    }
}

function Get-OAuthFlowDiagram {
    @"
    +-------------------+          +-------------------+          +-------------------+          +-------------------+
    |                   |          |                   |          |                   |          |                   |
    |     Client        |          |  Authorization    |          |                   |          |                   |
    |                   |          |      Server       |          |                   |          |                   |
    +-------------------+          +-------------------+          +-------------------+          +-------------------+
              |                            |
              | (1) Authorization Request  |
              |--------------------------->|
              |                            |
              |                            |
              | (2) Authorization Code     |
              |<---------------------------|
              |                            |
              |                            |
              | (3) Token Request          |
              |--------------------------->|
              |                            |
              |                            |
              | (4) Access Token           |
              |<---------------------------|
              |                            |
    +-------------------+          +-------------------+
    |                   |          |                   |
    |     Resource      |          |      API          |
    |                   |          |                   |
    +-------------------+          +-------------------+
              |                            |
              | (5) API Request            |
              |--------------------------->|
              |                            |
              |                            |
              | (6) API Response           |
              |<---------------------------|
              |                            |
    +-------------------+          +-------------------+
    |                   |          |                   |
    |                   |          |                   |
    |                   |          |                   |
    +-------------------+          +-------------------+
"@
}



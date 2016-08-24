Function New-UnitySMTPServer {

  <#
      .SYNOPSIS
      Create a new SMTP server (Default or PhoneHome).
      .DESCRIPTION
      Create a new SMTP server (Default or PhoneHome).
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specify an UnitySession Object.
      .PARAMETER address
      IP address of the SMTP server.
      .PARAMETER type
      SMTP server type. Might be:
      - Default
      - PhoneHome
      .PARAMETER Confirm
      If the value is $true, indicates that the cmdlet asks for confirmation before running. If the value is $false, the cmdlet runs without asking for user confirmation.
      .PARAMETER WhatIf
      Indicate that the cmdlet is run only to display the changes that would be made and actually no objects are modified.
      .EXAMPLE
      New-UnitySMTPServer -address 'smtp.example.com' -type 'default'

      Create a new default SMTP server.
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $true,HelpMessage = 'IP address of the SMTP server.')]
    [string]$address,
    [Parameter(Mandatory = $true,HelpMessage = 'SMTP server type.')]
    [SmtpTypeEnum]$type
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"

    #Initialazing arrays
    $ResultCollection = @()
  }

  Process {
    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      #Creation of the body hash
      $body = @{}

      #Body arguments
      $body["address"] = $address
      $body["type"] = $type

      If ($Sess.TestConnection()) {

        #Building the URI
        $URI = 'https://'+$sess.Server+'/api/types/smtpServer/instances'
        Write-Verbose "URI: $URI"

        #Sending the request
        If ($pscmdlet.ShouldProcess($($Sess.Server),"Create a new SMTP Server.")) {
          $request = Send-UnityRequest -uri $URI -Session $Sess -Method 'POST' -Body $Body
        }

        Write-Verbose "Request status code: $($request.StatusCode)"

        If ($request.StatusCode -eq '201') {

          #Formating the result. Converting it from JSON to a Powershell object
          $results = ($request.content | ConvertFrom-Json).content

          Write-Verbose "SMTP Server created with the ID: $($results.id) "

          #Executing Get-UnityUser with the ID of the new user
          Get-UnitySMTPServer -Session $Sess -ID $results.id
        }
      } else {
        Write-Information -MessageData "You are no longer connected to EMC Unity array: $($Sess.Server)"
      }

    }
  }

  End {}
}

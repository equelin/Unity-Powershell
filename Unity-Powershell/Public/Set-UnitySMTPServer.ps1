Function Set-UnitySMTPServer {

  <#
      .SYNOPSIS
      Modifies SMTP Server.
      .DESCRIPTION
      Modifies SMTP Server.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specify an UnitySession Object.
      .PARAMETER ID
      Management interface ID or Object.
      .PARAMETER address
      IP address of the SMTP server.
      .PARAMETER Confirm
      If the value is $true, indicates that the cmdlet asks for confirmation before running. If the value is $false, the cmdlet runs without asking for user confirmation.
      .PARAMETER WhatIf
      Indicate that the cmdlet is run only to display the changes that would be made and actually no objects are modified.
      .EXAMPLE
      Set-UnitySMTPServer -ID 'ID01' -Description 'New description'

      Modifies the SMTP Server with id 'ID01'
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    #Default Parameters
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),

    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'ID of the SMTP Server')]
    [String]$ID,
    [Parameter(Mandatory = $true,HelpMessage = 'IP address of the SMTP server.')]
    [String]$address
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"
  }

  Process {

    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If ($Sess.TestConnection()) {

        # Determine input and convert to UnitySMTPServer object

        Write-Verbose "Input object type is $($ID.GetType().Name)"
        Switch ($ID.GetType().Name)
        {
          "String" {
            $SMTPServer = get-UnitySMTPServer -Session $Sess -ID $ID
            $SMTPServerID = $SMTPServer.id
          }
          "UnitySMTPServer" {
            $SMTPServerID = $ID.id
          }
        }

        If ($SMTPServerID) {

          # Creation of the body hash
          $body = @{}

          $body["address"] = $address

          #Building the URI
          $URI = 'https://'+$sess.Server+'/api/instances/smtpServer/'+$SMTPServerID+'/action/modify'
          Write-Verbose "URI: $URI"

          #Sending the request
          If ($pscmdlet.ShouldProcess($SMTPServerID,"Modify SMTP Server")) {
            $request = Send-UnityRequest -uri $URI -Session $Sess -Method 'POST' -Body $Body
          }

          If ($request.StatusCode -eq '204') {

            Write-Verbose "SMTP Server with ID: $SMTPServerID has been modified"

            Get-UnitySMTPServer -Session $Sess -id $SMTPServerID

          }
        } else {
          Write-Verbose "SMTP Server $SMTPServerID does not exist on the array $($sess.Name)"
        }
      } else {
        Write-Information -MessageData "You are no longer connected to EMC Unity array: $($Sess.Server)"
      }
    }
  }

  End {}
}

Function Remove-UnitySMTPServer {

  <#
      .SYNOPSIS
      Delete SMTP Server.
      .DESCRIPTION
      Delete SMTP Server.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specify an UnitySession Object.
      .PARAMETER ID
      Management interface ID or Object.
      .PARAMETER Confirm
      If the value is $true, indicates that the cmdlet asks for confirmation before running. 
      If the value is $false, the cmdlet runs without asking for user confirmation.
      .PARAMETER WhatIf
      Indicate that the cmdlet is run only to display the changes that would be made and actually no objects are modified.
      .EXAMPLE
      Remove-UnitySMTPServer -ID 'default'

      Delete the SMTP server with ID 'default'
      .EXAMPLE
      Get-UnitySMTPServer -Name 'default' | Remove-UnitySMTPServer

      Delete the SMTP server with ID 'default'. SMTP server informations are provided by the Get-UnitySMTPServer through the pipeline.
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'SMTP Server ID or Object')]
    $ID
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"
  }

  Process {

    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If ($Sess.TestConnection()) {

        Foreach ($i in $ID) {

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
            #Building the URI
            $URI = 'https://'+$sess.Server+'/api/instances/smtpServer/'+$SMTPServerID
            Write-Verbose "URI: $URI"

            if ($pscmdlet.ShouldProcess($SMTPServerID,"Delete File Interface")) {
              #Sending the request
              $request = Send-UnityRequest -uri $URI -Session $Sess -Method 'DELETE'
            }

            If ($request.StatusCode -eq '204') {

              Write-Verbose "SMTP Server with ID: $id has been deleted"

            }
          } else {
            Write-Information -MessageData "SMTP Server $SMTPServerID does not exist on the array $($sess.Name)"
          }
        }
      } else {
        Write-Information -MessageData "You are no longer connected to EMC Unity array: $($Sess.Server)"
      }
    }
  }

  End {}
}

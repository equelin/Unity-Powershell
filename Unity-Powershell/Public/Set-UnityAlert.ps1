Function Set-UnityAlert {

  <#
      .SYNOPSIS
      Update the "ack" status of alert.
      .DESCRIPTION
      Update the "ack" status of alert.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specify an UnitySession Object.
      .PARAMETER ID
      Management interface ID or Object.
      .PARAMETER isAcknowledged
      Whether alert is acknowledged.
      .PARAMETER Confirm
      If the value is $true, indicates that the cmdlet asks for confirmation before running. If the value is $false, the cmdlet runs without asking for user confirmation.
      .PARAMETER WhatIf
      Indicate that the cmdlet is run only to display the changes that would be made and actually no objects are modified.
      .EXAMPLE
      Set-UnityAlert -ID 'alert_38' -isAcknowledged $True

      Acknoledge alert with id 'alert_38'
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    #Default Parameters
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),

    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'ID or Object')]
    [String]$ID,
    [Parameter(Mandatory = $true,HelpMessage = 'Whether alert is acknowledged.')]
    [bool]$isAcknowledged
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"
  }

  Process {

    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If ($Sess.TestConnection()) {

        # Determine input and convert to UnityAlert object

        Write-Verbose "Input object type is $($ID.GetType().Name)"
        Switch ($ID.GetType().Name)
        {
          "String" {
            $Alert = get-UnityAlert -Session $Sess -ID $ID
            $AlertID = $Alert.id
          }
          "UnityAlert" {
            $AlertID = $ID.id
          }
        }

        If ($AlertID) {

          # Creation of the body hash
          $body = @{}

          $body["isAcknowledged"] = $isAcknowledged

          #Building the URI
          $URI = 'https://'+$sess.Server+'/api/instances/alert/'+$AlertID+'/action/modify'
          Write-Verbose "URI: $URI"

          #Sending the request
          If ($pscmdlet.ShouldProcess($AlertID,"Modify alert")) {
            $request = Send-UnityRequest -uri $URI -Session $Sess -Method 'POST' -Body $Body
          }

          If ($request.StatusCode -eq '204') {

            Write-Verbose "Alert with ID: $AlertID has been modified"

            Get-UnityAlert -Session $Sess -id $AlertID

          }
        } else {
          Write-Verbose "Alert $AlertID does not exist on the array $($sess.Name)"
        }
      } else {
        Write-Information -MessageData "You are no longer connected to EMC Unity array: $($Sess.Server)"
      }
    }
  }

  End {}
}

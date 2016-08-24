Function Remove-UnityAlert {

  <#
      .SYNOPSIS
      Delete alert.
      .DESCRIPTION
      Delete alert.
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
      If the value is $true, indicates that the cmdlet asks for confirmation before running. If the value is $false, the cmdlet runs without asking for user confirmation.
      .PARAMETER WhatIf
      Indicate that the cmdlet is run only to display the changes that would be made and actually no objects are modified.
      .EXAMPLE
      Remove-UnityAlert -ID 'alert_28'

      Delete the Alert with ID 'alert_28'
      .EXAMPLE
      Get-UnityAlert -Name 'alert_28' | Remove-UnityAlert

      Delete the Alert with ID 'alert_28'. Alert informations are provided by the Get-UnityAlert through the pipeline.
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'ID or Object')]
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
            #Building the URI
            $URI = 'https://'+$sess.Server+'/api/instances/alert/'+$AlertID
            Write-Verbose "URI: $URI"

            if ($pscmdlet.ShouldProcess($AlertID,"Delete alert")) {
              #Sending the request
              $request = Send-UnityRequest -uri $URI -Session $Sess -Method 'DELETE'
            }

            If ($request.StatusCode -eq '204') {

              Write-Verbose "Alert with ID: $id has been deleted"

            }
          } else {
            Write-Information -MessageData "Alert $AlertID does not exist on the array $($sess.Name)"
          }
        }
      } else {
        Write-Information -MessageData "You are no longer connected to EMC Unity array: $($Sess.Server)"
      }
    }
  }

  End {}
}

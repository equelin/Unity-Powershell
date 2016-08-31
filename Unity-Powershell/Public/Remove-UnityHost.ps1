Function Remove-UnityHost {

  <#
      .SYNOPSIS
      Delete host.
      .DESCRIPTION
      Delete host.
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
      Remove-UnityHost -ID 'host_5'

      Delete the host with ID 'host_5'
      .EXAMPLE
      Get-UnityHost -ID 'host_5' | Remove-UnityHost
    
      Delete the host with ID 'host_5'. host informations are provided by the Get-UnityHost through the pipeline.
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Host ID or Object')]
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

          # Determine input and convert to UnityHost object
          Write-Verbose "Input object type is $($I.GetType().Name)"
          Switch ($I.GetType().Name)
          {
            "String" {
              $Host = get-UnityHost -Session $Sess -ID $I
              $HostID = $Host.id
            }
            "UnityHost" 
            {
              $HostID = $I.id
            }
          }

          If ($HostID) {
            #Building the URI
            $URI = 'https://'+$sess.Server+'/api/instances/host/'+$HostID
            Write-Verbose "URI: $URI"

            if ($pscmdlet.ShouldProcess($HostID,"Delete Host")) {
              #Sending the request
              $request = Send-UnityRequest -uri $URI -Session $Sess -Method 'DELETE'
            }

            If ($request.StatusCode -eq '204') {

              Write-Verbose "host with ID: $id has been deleted"

            }
          } else {
            Write-Information -MessageData "host $HostID does not exist on the array $($sess.Name)"
          }
        }
      } else {
        Write-Information -MessageData "You are no longer connected to EMC Unity array: $($Sess.Server)"
      }
    }
  }

  End {}
}

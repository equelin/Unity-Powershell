Function Remove-UnityvCenter {

  <#
      .SYNOPSIS
      Delete vCenter Server.
      .DESCRIPTION
      Delete vCenter Server.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specify an UnitySession Object.
      .PARAMETER ID
      vCenter ID or Object.
      .PARAMETER Confirm
      If the value is $true, indicates that the cmdlet asks for confirmation before running. 
      If the value is $false, the cmdlet runs without asking for user confirmation.
      .PARAMETER WhatIf
      Indicate that the cmdlet is run only to display the changes that would be made and actually no objects are modified.
      .EXAMPLE
      Remove-UnityvCenter -ID 'default'

      Delete the vCenter server with ID 'default'
      .EXAMPLE
      Get-UnityvCenter -Name 'default' | Remove-UnityvCenter

      Delete the vCenter server with ID 'default'. vCenter server informations are provided by the Get-UnityvCenter through the pipeline.
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'vCenter Server ID or Object')]
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

          # Determine input and convert to UnityvCenter object
          Write-Verbose "Input object type is $($I.GetType().Name)"
          Switch ($I.GetType().Name)
          {
            "String" {
              $vCenterServer = get-UnityvCenter -Session $Sess -ID $ID
              $vCenterServerID = $vCenterServer.id
            }
            "UnityHostContainer" {
              $vCenterServerID = $I.id
            }
          }

          If ($vCenterServerID) {
            #Building the URI
            $URI = 'https://'+$sess.Server+'/api/instances/hostContainer/'+$vCenterServerID
            Write-Verbose "URI: $URI"

            if ($pscmdlet.ShouldProcess($vCenterServerID,"Delete vCenter Server")) {
              #Sending the request
              $request = Send-UnityRequest -uri $URI -Session $Sess -Method 'DELETE'
            }

            If ($request.StatusCode -eq '204') {

              Write-Verbose "vCenter Server with ID: $vCenterServerID has been deleted"

            }
          } else {
            Write-Information -MessageData "vCenter Server $vCenterServerID does not exist on the array $($sess.Name)"
          }
        }
      } else {
        Write-Information -MessageData "You are no longer connected to EMC Unity array: $($Sess.Server)"
      }
    }
  }

  End {}
}

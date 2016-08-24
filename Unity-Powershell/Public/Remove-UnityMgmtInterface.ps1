Function Remove-UnityMgmtInterface {

  <#
      .SYNOPSIS
      Delete a file interface.
      .DESCRIPTION
      Delete a Nas Server.
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
      Remove-UnityMgmtInterface -ID 'mgmt_ipv4'

      Delete the management interface with ID 'mgmt_ipv4'
      .EXAMPLE
      Get-UnityMgmtInterface -Name 'mgmt_ipv4' | Remove-UnityMgmtInterface

      Delete the management interface with ID 'mgmt_ipv4'. The management interface informations are provided by the Get-UnityMgmtInterface through the pipeline.
  #>

    [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Management interface ID or Object')]
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

        # Determine input and convert to UnityMgmtInterface object
        Switch ($ID.GetType().Name)
        {
          "String" {
            $MgmtInterface = get-UnityMgmtInterface -Session $Sess -ID $ID
            $MgmtInterfaceID = $MgmtInterface.id
          }
          "UnityMgmtInterface" {
            Write-Verbose "Input object type is $($ID.GetType().Name)"
            $MgmtInterfaceID = $ID.id
          }
        }

          If ($MgmtInterfaceID) {
            #Building the URI
            $URI = 'https://'+$sess.Server+'/api/instances/mgmtInterface/'+$MgmtInterfaceID
            Write-Verbose "URI: $URI"

            if ($pscmdlet.ShouldProcess($MgmtInterfaceID,"Delete management interface. WARNING: You might be disconnected from the interface.")) {
              #Sending the request
              $request = Send-UnityRequest -uri $URI -Session $Sess -Method 'DELETE'
            }

            If ($request.StatusCode -eq '204') {

              Write-Verbose "Management Interface with ID: $id has been deleted"

            }
          } else {
            Write-Information -MessageData "Management Interface $MgmtInterfaceID does not exist on the array $($sess.Name)"
          }
        }
      } else {
        Write-Information -MessageData "You are no longer connected to EMC Unity array: $($Sess.Server)"
      }
    }
  }

  End {}
}

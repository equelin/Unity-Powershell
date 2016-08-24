Function Remove-UnityFileInterface {

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
      File Interface ID or Object.
      .PARAMETER Confirm
      If the value is $true, indicates that the cmdlet asks for confirmation before running. If the value is $false, the cmdlet runs without asking for user confirmation.
      .PARAMETER WhatIf
      Indicate that the cmdlet is run only to display the changes that would be made and actually no objects are modified.
      .EXAMPLE
      Remove-UnityFileInterface -ID 'if_1'

      Delete the file interface with ID 'if_1'
      .EXAMPLE
      Get-UnityFileInterface -Name 'if_1' | Remove-UnityFileInterface

      Delete the file interface with ID 'if_1'. The file interface informations are provided by the Get-UnityFileInterface through the pipeline.
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'File interface ID or Object')]
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

          # Determine input and convert to UnityFileInterface object
          Switch ($ID.GetType().Name)
          {
            "String" {
              $FileInterface = get-UnityFileInterface -Session $Sess -ID $ID
              $FileInterfaceID = $FileInterface.id
              $FileInterfaceName = $FileInterface.Name
            }
            "UnityFileInterface" {
              Write-Verbose "Input object type is $($ID.GetType().Name)"
              $FileInterfaceID = $ID.id
              If ($FileInterface = Get-UnityFileInterface -Session $Sess -ID $FileInterfaceID) {
                        $FileInterfaceName = $ID.name
              }
            }
          }

          If ($FileInterfaceID) {
            #Building the URI
            $URI = 'https://'+$sess.Server+'/api/instances/fileInterface/'+$FileInterfaceID
            Write-Verbose "URI: $URI"

            if ($pscmdlet.ShouldProcess($FileInterfaceID,"Delete File Interface")) {
              #Sending the request
              $request = Send-UnityRequest -uri $URI -Session $Sess -Method 'DELETE'
            }

            If ($request.StatusCode -eq '204') {

              Write-Verbose "File Interface with ID: $id has been deleted"

            }
          } else {
            Write-Information -MessageData "File Interface $FileInterfaceID does not exist on the array $($sess.Name)"
          }
        }
      } else {
        Write-Information -MessageData "You are no longer connected to EMC Unity array: $($Sess.Server)"
      }
    }
  }

  End {}
}

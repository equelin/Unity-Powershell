Function Remove-UnityNASServer {

  <#
      .SYNOPSIS
      Delete a Nas Server.
      .DESCRIPTION
      Delete a Nas Server.
      Before you can delete a NAS server, you must first delete all storage resources associated with it.
      Deleting a NAS server removes everything configured on the NAS server, but does not delete the storage resources that use it. 
      You cannot delete a NAS server while it has any associated storage resources.
      After the storage resources are deleted, the files and folders inside them cannot be restored from snapshots.
      Back up the data from the storage resources before deleting them from the system.

      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under Apache licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specifies an UnitySession Object.
      .PARAMETER Name
      Specifies the NAS server name.
      .EXAMPLE
      Remove-UnityNasServer -Name 'NAS01'

      Delete the Nas Server named 'NAS01'
      .EXAMPLE
      Get-UnityNasServer -Name 'NAS01' | Remove-UnityNasServer

      Delete the Nas Server named 'NAS01'. The NAS server's informations are provided by the Get-UnityNasServer through the pipeline.
  #>

    [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    #Default Parameters
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    
    #NasServer
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Pool Name or Pool Object')]
    $Name
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"
  }

  Process {

    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If ($Sess.TestConnection()) {

        Foreach ($n in $Name) {

          # Determine input and convert to UnityPool object
          Switch ($n.GetType().Name)
          {
            "String" {
              $NasServer = Get-UnityNasServer -Session $Sess -Name $n
              $NasServerID = $NasServer.id
              $NasServerName = $NasServer.Name
            }
            "UnityNasServer" {
              Write-Verbose "Input object type is $($n.GetType().Name)"
              $NasServerName = $n.Name
              If ($NasServer = Get-UnityNasServer -Session $Sess -Name $NasServerName) {
                        $NasServerID = $n.id
              }
            }
          }

          If ($NasServerID) {
            #Building the URI
            $URI = 'https://'+$sess.Server+'/api/instances/nasServer/'+$NasServerID
            Write-Verbose "URI: $URI"

            if ($pscmdlet.ShouldProcess($NasServerName,"Delete NAS Server")) {
              #Sending the request
              $request = Send-UnityRequest -uri $URI -Session $Sess -Method 'DELETE'
            }

            If ($request.StatusCode -eq '204') {

              Write-Verbose "Pool with ID: $id has been deleted"

            }
          } else {
            Write-Information -MessageData "LUN $NasServerName does not exist on the array $($sess.Name)"
          }
        }
      } else {
        Write-Information -MessageData "You are no longer connected to EMC Unity array: $($Sess.Server)"
      }
    }
  }

  End {}
}

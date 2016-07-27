Function Remove-UnityCIFSShare {

  <#
      .SYNOPSIS
      Deletes CIFS share.
      .DESCRIPTION
      Deletes CIFS share.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under Apache licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .EXAMPLE
      Remove-UnityCIFSShare -ID 'SMBShare_1'

      Delete the CIFS share with id 'SMBShare_1'
  #>

    [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    #Default Parameters
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),

    #cifsShareDelete
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'ID of the CIFS share')]
    [String[]]$ID
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"
  }

  Process {

    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If ($Sess.TestConnection()) {

        Foreach ($i in $ID) {

          # Determine input and convert to UnityFilesystem object
          Switch ($i.GetType().name)
          {
            "String" {
              $share = get-UnityCIFSShare -Session $Sess -ID $i
              $ShareID = $share.id
              $filesystemID = $share.filesystem.id
            }
            "UnityCIFSShare" {
              Write-Verbose "Input object type is $($i.GetType().Name)"
              If ($share = Get-UnityCIFSShare -Session $Sess -ID $i) {
                $ShareID = $share.id
                $filesystemID = $share.filesystem.id
              }
            }
          }

          If ($ShareID) {

            $UnityStorageRessource = Get-UnitystorageResource -Session $sess | Where-Object {($_.filesystem.id -like $filesystemID)}

            # Creation of the body hash
            $body = @{}

            $body["cifsShareDelete"] = @()

              $cifsShareDeleteParameters = @{}
                $cifsShareDeleteParameters["cifsShare"] = @{}
                  $cifsShareParameters = @{}
                  $cifsShareParameters['id'] = $ShareID
                $cifsShareDeleteParameters["cifsShare"] = $cifsShareParameters

            $body["cifsShareDelete"] += $cifsShareDeleteParameters

            #Building the URI
            $URI = 'https://'+$sess.Server+'/api/instances/storageResource/'+($UnityStorageRessource.id)+'/action/modifyFilesystem'
            Write-Verbose "URI: $URI"

            #Sending the request
            if ($pscmdlet.ShouldProcess($ShareID,"Delete CIFS Share")) {
              $request = Send-UnityRequest -uri $URI -Session $Sess -Method 'POST' -Body $Body
            }
            
            If ($request.StatusCode -eq '204') {

              Write-Verbose "CIFS Share named $name on filesystem $filesystemName has been deleted"

            }
          } else {
            Write-Verbose "CIFS Share $ShareID does not exist on the array $($sess.Name)"
          }
        }
      } else {
        Write-Information -MessageData "You are no longer connected to EMC Unity array: $($Sess.Server)"
      }
    }
  }

  End {}
}
  
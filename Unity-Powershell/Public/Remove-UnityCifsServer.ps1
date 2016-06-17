Function Remove-UnityCIFSServer {

  <#
      .SYNOPSIS
      Delete a Cifs Server.
      .DESCRIPTION
      Delete a Cifs Server.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under Apache licence
      .LINK
      https://github.com/equelin/Unity-Powershell
      .EXAMPLE
      Remove-UnityCifsServer -Name 'CIFS01'

      Delete the Cifs Server named 'CIFS01'
      .EXAMPLE
      Get-UnityCifsServer -Name 'CIFS01' | Remove-UnityCifsServer

      Delete the Cifs Server named 'CIFS01'. The Cifs Server's informations are provided by the Get-UnityNasServer through the pipeline.
  #>

    [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'CIFS Server Name or CIFS Server Object')]
    $Name,
    [Parameter(Mandatory = $false,HelpMessage = 'Keep SMB server account unjoined in Active Directory after deletion')]
    [bool]$skipUnjoin,
    [Parameter(Mandatory = $false,HelpMessage = 'Username for unjoin')]
    [String]$domainUsername,
    [Parameter(Mandatory = $false,HelpMessage = 'Password for unjoin')]
    [String]$domainPassword
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"
  }

  Process {

    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If (Test-UnityConnection -Session $Sess) {

        Foreach ($n in $Name) {

          # Creation of the body hash
          $body = @{}

          If ($PSBoundParameters.ContainsKey('skipUnjoin')) {
            $body["skipUnjoin"] = $skipUnjoin
          }

          If ($PSBoundParameters.ContainsKey('domainUsername')) {
            $body["domainUsername"] = "$domainUsername"
          }

          If ($PSBoundParameters.ContainsKey('domainPassword')) {
            $body["domainPassword"] = $domainPassword
          }

          # Determine input and convert to UnityCIFSServer object
          Switch ($n.GetType().Name)
          {
            "String" {
              $NasServer = Get-UnityCifsServer -Session $Sess -Name $n
              $NasServerID = $NasServer.id
              $NasServerName = $NasServer.Name
            }
            "UnityCifsServer" {
              Write-Verbose "Input object type is $($n.GetType().Name)"
              $NasServerName = $n.Name
              If ($NasServer = Get-UnityCifsServer -Session $Sess -Name $NasServerName) {
                        $NasServerID = $n.id
              }
            }
          }

          If ($NasServerID) {
            #Building the URI
            $URI = 'https://'+$sess.Server+'/api/instances/cifsServer/'+$NasServerID
            Write-Verbose "URI: $URI"

            if ($pscmdlet.ShouldProcess($NasServerName,"Delete Cifs Server")) {
              #Sending the request
              $request = Send-UnityRequest -uri $URI -Session $Sess -Method 'DELETE' -Body $body
            }

            If ($request.StatusCode -eq '204') {

              Write-Verbose "CIFS Server with ID: $id has been deleted"

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

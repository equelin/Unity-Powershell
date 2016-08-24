Function Remove-UnityFileDNSServer {

  <#
      .SYNOPSIS
      Delete a file DNS Server.
      .DESCRIPTION
      Delete a file DNS Server.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specify an UnitySession Object.
      .PARAMETER ID
      File DNS ID or Object.
      .PARAMETER Confirm
      If the value is $true, indicates that the cmdlet asks for confirmation before running. If the value is $false, the cmdlet runs without asking for user confirmation.
      .PARAMETER WhatIf
      Indicate that the cmdlet is run only to display the changes that would be made and actually no objects are modified.
      .EXAMPLE
      Remove-UnityFileDnsServer -ID 'dns_1'

      Delete the file DNS server with ID 'dns_1'
      .EXAMPLE
      Get-UnityFileDnsServer | Remove-UnityFileDnsServer

      Delete all the file DNS Servers
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'File DNS ID or Object')]
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

          # Determine input and convert to UnityFileDnsServer object
          Switch ($ID.GetType().Name)
          {
            "String" {
              $FileDNSServer = get-UnityFileDnsServer -Session $Sess -ID $ID
              $FileDNSServerID = $FileDNSServer.id
              $FileDNSServerName = $FileDNSServer.Name
            }
            "UnityFileDnsServer" {
              Write-Verbose "Input object type is $($ID.GetType().Name)"
              $FileDNSServerID = $ID.id
              If ($FileDNSServer = Get-UnityFileDnsServer -Session $Sess -ID $FileDNSServerID) {
                        $FileDNSServerName = $ID.name
              }
            }
          }

          If ($FileDNSServerID) {
            #Building the URI
            $URI = 'https://'+$sess.Server+'/api/instances/fileDNSServer/'+$FileDNSServerID
            Write-Verbose "URI: $URI"

            if ($pscmdlet.ShouldProcess($FileDNSServerID,"Delete File DNS Server")) {
              #Sending the request
              $request = Send-UnityRequest -uri $URI -Session $Sess -Method 'DELETE'
            }

            If ($request.StatusCode -eq '204') {

              Write-Verbose "File DNS Server with ID: $id has been deleted"

            }
          } else {
            Write-Information -MessageData "File DNS $FileDNSServerID does not exist on the array $($sess.Name)"
          }
        }
      } else {
        Write-Information -MessageData "You are no longer connected to EMC Unity array: $($Sess.Server)"
      }
    }
  }

  End {}
}

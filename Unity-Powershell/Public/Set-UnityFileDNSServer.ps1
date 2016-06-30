Function Set-UnityFileDnsServer {

  <#
      .SYNOPSIS
      Modifies File DNS Server parameters.
      .DESCRIPTION
      Modifies File DNS Server parameters.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under Apache licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .EXAMPLE
      Set-UnityFileDnsServer -ID 'dns_1' -ipAddress '192.168.0.1'

      Change ip of the file DNS server with ID 'dns_1'
  #>

    [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'File interface ID or Object')]
    $ID,
    [Parameter(Mandatory = $false,HelpMessage = 'DNS domain name')]
    [string]$domain,
    [Parameter(Mandatory = $false,HelpMessage = 'Prioritized list of one to three IPv4 and/or IPv6 addresses of DNS servers for the domain')]
    [String[]]$addresses,
    [Parameter(Mandatory = $false,HelpMessage = 'replication policy')]
    [ReplicationPolicyEnum]$replicationPolicy
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"

  }

  Process {

    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If (Test-UnityConnection -Session $Sess) {

        # Determine input and convert to UnityPool object
        Switch ($ID.GetType().Name)
        {
          "String" {
            $FileDNSServer = get-UnityFileDNSServer -Session $Sess -ID $ID
            $FileDNSServerID = $FileDNSServer.id
            $FileDNSServerName = $FileDNSServer.Name
          }
          "UnityFileInterface" {
            Write-Verbose "Input object type is $($ID.GetType().Name)"
            $FileDNSServerID = $ID.id
            If ($FileDNSServer = Get-UnityFileDNSServer -Session $Sess -ID $FileDNSServerID) {
                      $FileDNSServerName = $ID.name
            }
          }
        }

        If ($FileDNSServerID) {

          # Creation of the body hash
          $body = @{}

          #Addresses argument
          $body['addresses'] = @()
          Foreach ($Addresse in $Addresses) {
            $body["addresses"] += $Addresse
          }

          If ($PSBoundParameters.ContainsKey('domain')) {
                $body["domain"] = "$($domain)"
          }

          If ($PSBoundParameters.ContainsKey('replicationPolicy')) {
                $body["replicationPolicy"] = $replicationPolicy
          }

          #Building the URI
          $URI = 'https://'+$sess.Server+'/api/instances/fileDNSServer/'+$FileDNSServerID+'/action/modify'
          Write-Verbose "URI: $URI"

          #Sending the request
          If ($pscmdlet.ShouldProcess($FileDNSServerID,"Modify File DNS Server Interface")) {
            $request = Send-UnityRequest -uri $URI -Session $Sess -Method 'POST' -Body $Body
          }

          If ($request.StatusCode -eq '204') {

            Write-Verbose "File DNS Server with ID: $FileDNSServerID has been modified"

            Get-UnityFileDNSServer -Session $Sess -id $FileDNSServerID

          }
        } else {
          Write-Verbose "NAS Server $FileDNSServerID does not exist on the array $($sess.Name)"
        }
      } else {
        Write-Information -MessageData "You are no longer connected to EMC Unity array: $($Sess.Server)"
      }
    }
  }

  End {}
}

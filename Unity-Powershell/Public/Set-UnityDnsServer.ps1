Function Set-UnityDNSServer {

  <#
      .SYNOPSIS
      Modifies DNS Servers parameters.
      .DESCRIPTION
      Modifies DNS Servers parameters.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under Apache licence
      .LINK
      https://github.com/equelin/Unity-Powershell
      .EXAMPLE
      Set-UnityDnsServer -Addresses '192.168.0.1','192.168.0.2'

      replace the exsting address list for this DNS server with this new list.
  #>

    [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'LUN Name or LUN Object')]
    [String[]]$Addresses
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"
  }

  Process {

    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If (Test-UnityConnection -Session $Sess) {

          $DnsServer = Get-UnityDnsServer -Session $Sess

          # Creation of the body hash
          $body = @{}
          $body['addresses'] = @()

          Foreach ($Addresse in $Addresses) {
            $body["addresses"] += $Addresse
          }

          #Building the URI
          $URI = 'https://'+$sess.Server+'/api/instances/dnsServer/'+($DnsServer.id)+'/action/modify'
          Write-Verbose "URI: $URI"

          #Sending the request
          If ($pscmdlet.ShouldProcess($($DnsServer.id),"Modify DNS Server")) {
            $request = Send-UnityRequest -uri $URI -Session $Sess -Method 'POST' -Body $Body
          }

          If ($request.StatusCode -eq '204') {

            Write-Verbose "DNS Server has been modified"

            Get-UnityDnsServer -Session $Sess
          }

      } else {
        Write-Information -MessageData "You are no longer connected to EMC Unity array: $($Sess.Server)"
      }
    }
  }

  End {}
}

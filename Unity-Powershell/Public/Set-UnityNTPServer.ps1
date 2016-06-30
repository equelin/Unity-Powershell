Function Set-UnityNTPServer {

  <#
      .SYNOPSIS
      Modifies NTP Servers parameters.
      .DESCRIPTION
      Modifies NTP Servers parameters.
      You can configure a total of four NTP server addresses for the system. 
      All NTP server addresses are grouped into a single NTP server record. 
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under Apache licence
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Addresses
      List of NTP server IP addresses.
      .PARAMETER rebootPrivilege
      Indicates whether a system reboot of the NTP server is required for setting the system time.
      .EXAMPLE
      Set-UnityNTPServer -Addresses '192.168.0.1','192.168.0.2'

      replace the exsting address list for this NTP server with this new list.
  #>

    [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'List of NTP server IP addresses.')]
    [String[]]$Addresses,
    [Parameter(Mandatory = $false,HelpMessage = 'Indicates whether a system reboot of the NTP server is required for setting the system time.')]
    [RebootPrivilegeEnum]$rebootPrivilege = 'No_Reboot_Allowed'
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"
  }

  Process {

    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If (Test-UnityConnection -Session $Sess) {

          $NTPServer = Get-UnityNTPServer -Session $Sess

          # Creation of the body hash
          $body = @{}
          $body['addresses'] = @()

          Foreach ($Addresse in $Addresses) {
            $body["addresses"] += $Addresse
          }

          $body["rebootPrivilege"] = $rebootPrivilege

          #Building the URI
          $URI = 'https://'+$sess.Server+'/api/instances/ntpServer/'+($NTPServer.id)+'/action/modify'
          Write-Verbose "URI: $URI"

          #Sending the request
          If ($pscmdlet.ShouldProcess($($NTPServer.id),"Modify NTP Server")) {
            $request = Send-UnityRequest -uri $URI -Session $Sess -Method 'POST' -Body $Body
          }

          Write-Verbose "Request Status Code: $($request.StatusCode)"

          If ($request.StatusCode -eq '204') {

            Write-Verbose "NTP Server has been modified"

            Get-UnityNTPServer -Session $Sess
          }

          If ($request.StatusCode -eq '202') {

            Write-Host "NTP Server has been modified. Array might reboot depending of the parameters you provided."

          }

      } else {
        Write-Host "You are no longer connected to EMC Unity array: $($Sess.Server)"
      }
    }
  }

  End {}
}

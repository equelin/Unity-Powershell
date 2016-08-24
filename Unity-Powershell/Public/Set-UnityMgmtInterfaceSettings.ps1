Function Set-UnityMgmtInterfaceSettings {

  <#
      .SYNOPSIS
      Modifies global management interfaces settings.
      .DESCRIPTION
      Modifies global management interfaces settings.
      It is not allowed to set both IPv4 and IPv6 to Disabled at the same time, in any sequence.
      It is not allowed to set both IPv4 and IPv6 to Auto in one request.
      IPv4 or IPv6 may be set to Auto only if the other class IP address already exists, either set as a static IP address or obtained in Auto mode.
      The Static can be set only implicitly by creating the mgmtInterface object. 
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specify an UnitySession Object.
      .PARAMETER v4ConfigMode
      New IPv4 config mode. Might be:
      - Disabled: Management access is disabled. 
      - Static: Management interface address is set manually with Set-UnityMgmtInterface.
      - Auto: Management interface address is configured by DHCP.
      .PARAMETER v6ConfigMode
      New IPv6 config mode. Might be:
      - Disabled: Management access is disabled. 
      - Static: Management interface address is set manually with Set-UnityMgmtInterface.
      - Auto: Management interface address is configured by SLAAC.
      .EXAMPLE
      Set-UnityMgmtInterfaceSettings -Addresses '192.168.0.1','192.168.0.2'

      replace the exsting address list for this DNS server with this new list.
  #>

    [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    
    [Parameter(Mandatory = $false,HelpMessage = 'New IPv4 config mode. Might be Disabled, Static or Auto')]
    [InterfaceConfigModeEnum]$v4ConfigMode,
    [Parameter(Mandatory = $false,HelpMessage = 'New IPv6 config mode. Might be Disabled, Static or Auto')]
    [InterfaceConfigModeEnum]$v6ConfigMode
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"
  }

  Process {

    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If ($Sess.TestConnection()) {

          # Creation of the body hash
          $body = @{}

          If ($PSBoundParameters.ContainsKey('v4ConfigMode')) {
            $body["v4ConfigMode"] = $v4ConfigMode
          }

          If ($PSBoundParameters.ContainsKey('v6ConfigMode')) {
            $body["v6ConfigMode"] = $v6ConfigMode
          }

          #Building the URI
          $URI = 'https://'+$sess.Server+'/api/instances/mgmtInterfaceSettings/0/action/modify'
          Write-Verbose "URI: $URI"

          #Sending the request
          If ($pscmdlet.ShouldProcess($($Sess.Server),"Modify mgmt interface settings")) {
            $request = Send-UnityRequest -uri $URI -Session $Sess -Method 'POST' -Body $Body
          }

          If ($request.StatusCode -eq '204') {

            Write-Verbose "Global management interfaces settings has been modified"

            Get-UnityMgmtInterfaceSettings -Session $Sess
          }

      } else {
        Write-Information -MessageData "You are no longer connected to EMC Unity array: $($Sess.Server)"
      }
    }
  }

  End {}
}

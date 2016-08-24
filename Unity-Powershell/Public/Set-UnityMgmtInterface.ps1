Function Set-UnityMgmtInterface {

  <#
      .SYNOPSIS
      Modify settings for an management interface. 
      .DESCRIPTION
      Modify settings for an management interface.  
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specify an UnitySession Object.
      .PARAMETER ID
      Management interface ID or Object.
      .PARAMETER ipAddress
      IPv4 or IPv6 address for the interface.
      .PARAMETER netmask
      IPv4 netmask for the interface, if the interface uses an IPv4 address.
      .PARAMETER v6PrefixLength
      Prefix length in bits for IPv6 address.
      .PARAMETER gateway
      IPv4 or IPv6 gateway address for the interface.
      .PARAMETER Confirm
      If the value is $true, indicates that the cmdlet asks for confirmation before running. If the value is $false, the cmdlet runs without asking for user confirmation.
      .PARAMETER WhatIf
      Indicate that the cmdlet is run only to display the changes that would be made and actually no objects are modified.
      .EXAMPLE
      Set-UnityMgmtInterface -ID 'mgmt_ipv4' -gateway '192.168.0.254'

      Change gateway of the management interface with ID 'mgmt_ipv4'
  #>

    [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Management interface ID or Object')]
    $ID,
    [Parameter(Mandatory = $false,Position = 1,HelpMessage = 'IPv4 or IPv6 address for the interface.')]
    [string]$ipAddress,
    [Parameter(Mandatory = $false,HelpMessage = 'IPv4 netmask for the interface, if the interface uses an IPv4 address.')]
    [string]$netmask,
    [Parameter(Mandatory = $false,HelpMessage = 'Prefix length in bits for IPv6 address.')]
    [String[]]$v6PrefixLength,
    [Parameter(Mandatory = $false,Position = 1,HelpMessage = 'IPv4 or IPv6 gateway address for the interface.')]
    [string]$gateway
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"
  }

  Process {

    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If ($Sess.TestConnection()) {

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

          # Creation of the body hash
          $body = @{}

          # ipAddress argument
          If ($PSBoundParameters.ContainsKey('ipAddress')) {
            $body["ipAddress"] = "$ipAddress"
          }

          If ($PSBoundParameters.ContainsKey('netmask')) {
            $body["netmask"] = "$netmask"
          }

          If ($PSBoundParameters.ContainsKey('v6PrefixLength')) {
            $body["v6PrefixLength"] = "$v6PrefixLength"
          }

          If ($PSBoundParameters.ContainsKey('gateway')) {
            $body["gateway"] = "$gateway"
          }

          #Building the URI
          $URI = 'https://'+$sess.Server+'/api/instances/mgmtInterface/'+$MgmtInterfaceID+'/action/modify'
          Write-Verbose "URI: $URI"

          #Sending the request
          If ($pscmdlet.ShouldProcess($MgmtInterfaceID,"Modify File Interface. WARNING: You might be disconnected from the interface.")) {
            $request = Send-UnityRequest -uri $URI -Session $Sess -Method 'POST' -Body $Body
          }

          If ($request.StatusCode -eq '204') {

            Write-Verbose "Management interface with ID: $MgmtInterfaceID has been modified"

            Get-UnityMgmtInterface -Session $Sess -id $MgmtInterfaceID

          }
        } else {
          Write-Verbose "Management interface $MgmtInterfaceID does not exist on the array $($sess.Name)"
        }
      } else {
        Write-Information -MessageData "You are no longer connected to EMC Unity array: $($Sess.Server)"
      }
    }
  }

  End {}
}

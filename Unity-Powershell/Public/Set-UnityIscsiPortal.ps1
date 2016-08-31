Function Set-UnityIscsiPortal {

  <#
      .SYNOPSIS
      Modify an iSCSI network portal. 
      .DESCRIPTION
      Modify an iSCSI network portal. 
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specify an UnitySession Object.
      .PARAMETER ID
      iSCSI Network Portal ID or Object.
      .PARAMETER ipAddress
      IPv4 or IPv6 address for the iSCSI Network Portal.
      .PARAMETER netmask
      IPv4 netmask for the iSCSI Network Portal, if the iSCSI Network Portal uses an IPv4 address.
      .PARAMETER v6PrefixLength
      Prefix length in bits for IPv6 address.
      .PARAMETER gateway
      IPv4 or IPv6 gateway address for the iSCSI Network Portal.
      .PARAMETER vlanId
      Ethernet virtual LAN identifier used for tagging iSCSI portal outgoing packets and for filtering iSCSI portal incoming packets.
      .PARAMETER Confirm
      If the value is $true, indicates that the cmdlet asks for confirmation before running. If the value is $false, the cmdlet runs without asking for user confirmation.
      .PARAMETER WhatIf
      Indicate that the cmdlet is run only to display the changes that would be made and actually no objects are modified.
      .EXAMPLE
      Set-UnityIscsiPortal -ID 'if_6' -vlanId 10

      Modifies the iSCSI network portal with id 'if_6'
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    #Default Parameters
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),

    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'iSCSI Network Portal ID or Oject')]
    [String]$ID,
    [Parameter(Mandatory = $false,HelpMessage = 'IPv4 or IPv6 address for the interface.')]
    [string]$ipAddress,
    [Parameter(Mandatory = $false,HelpMessage = 'IPv4 netmask for the interface, if the interface uses an IPv4 address.')]
    [string]$netmask,
    [Parameter(Mandatory = $false,HelpMessage = 'Prefix length in bits for IPv6 address.')]
    [String[]]$v6PrefixLength,
    [Parameter(Mandatory = $false,HelpMessage = 'Ethernet virtual LAN identifier used for tagging iSCSI portal outgoing packets and for filtering iSCSI portal incoming packets.')]
    [String[]]$vlanId,
    [Parameter(Mandatory = $false,HelpMessage = 'IPv4 or IPv6 gateway address for the interface.')]
    [string]$gateway
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"
  }

  Process {

    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If ($Sess.TestConnection()) {

        # Determine input and convert to UnityIscsiPortal object
        Write-Verbose "Input object type is $($ID.GetType().Name)"
        Switch ($ID.GetType().Name)
        {
          "String" {
            $IscsiPortal = get-UnityIscsiPortal -Session $Sess -ID $ID
            $IscsiPortalID = $IscsiPortal.id
          }
          "UnityIscsiPortal" {
            $IscsiPortalID = $ID.id
          }
        }

        If ($IscsiPortalID) {

          # Creation of the body hash
          $body = @{}

          If ($PSBoundParameters.ContainsKey('ipAddress')) {
            $body["ipAddress"] = $ipAddress
          }

          If ($PSBoundParameters.ContainsKey('netmask')) {
            $body["netmask"] = "$($netmask)"
          }

          If ($PSBoundParameters.ContainsKey('v6PrefixLength')) {
            $body["v6PrefixLength"] = "$($v6PrefixLength)"
          }

          If ($PSBoundParameters.ContainsKey('vlanId')) {
            $body["vlanId"] = "$($vlanId)"
          }

          If ($PSBoundParameters.ContainsKey('gateway')) {
            $body["gateway"] = "$($gateway)"
          }

          #Building the URI
          $URI = 'https://'+$sess.Server+'/api/instances/iscsiPortal/'+$IscsiPortalID+'/action/modify'
          Write-Verbose "URI: $URI"

          #Sending the request
          If ($pscmdlet.ShouldProcess($IscsiPortalID,"Modify iSCSI Network Portal")) {
            $request = Send-UnityRequest -uri $URI -Session $Sess -Method 'POST' -Body $Body
          }

          If ($request.StatusCode -eq '204') {

            Write-Verbose "iSCSI Network Portal with ID: $IscsiPortalID has been modified"

            Get-UnityIscsiPortal -Session $Sess -id $IscsiPortalID

          }
        } else {
          Write-Verbose "iSCSI Network Portal $IscsiPortalID does not exist on the array $($sess.Name)"
        }
      } else {
        Write-Information -MessageData "You are no longer connected to EMC Unity array: $($Sess.Server)"
      }
    }
  }

  End {}
}

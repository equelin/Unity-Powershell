Function New-UnityiSCSIPortal {

  <#
      .SYNOPSIS
      Create a new iSCSI portal.
      .DESCRIPTION
      Create a new iSCSI portal.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specify an UnitySession Object.
     .PARAMETER ethernetPort
      Ethernet port used by the iSCSI portal.
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
      New-UnityiSCSIPortal -ethernetPort 'spa_eth0' -ipAddress '192.168.0.1' -netmask '255.255.255.0' -gateway '192.168.0.254'

      Create a new iSCSI portal.
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $true,HelpMessage = 'Ethernet port ID.')]
    [string]$ethernetPort,
    [Parameter(Mandatory = $true,HelpMessage = 'IPv4 or IPv6 address for the interface.')]
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
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    ## Variables
    $URI = '/api/types/iscsiPortal/instances'
    $Type = 'iSCSI Portal'
    $StatusCode = 201
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      #### REQUEST BODY 

      #Creation of the body hash
      $body = @{}

      #Body arguments

      #ethernetPort parameter
      $body["ethernetPort"] = @{}
        $ethernetPortParameters = @{}
        $ethernetPortParameters["id"] = "$($ethernetPort)"
      $body["ethernetPort"] = $ethernetPortParameters

      $body["ipAddress"] = $ipAddress

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

      ####### END BODY - Do not edit beyond this line

      #Show $body in verbose message
      $Json = $body | ConvertTo-Json -Depth 10
      Write-Verbose $Json  

        If ($Sess.TestConnection()) {

          ##Building the URL
          $URL = 'https://'+$sess.Server+$URI
          Write-Verbose "URL: $URL"

          #Sending the request
          If ($pscmdlet.ShouldProcess($Sess.Name,"Create $Type $n")) {
            $request = Send-UnityRequest -uri $URL -Session $Sess -Method 'POST' -Body $Body
          }

          Write-Verbose "Request status code: $($request.StatusCode)"

          If ($request.StatusCode -eq $StatusCode) {

            #Formating the result. Converting it from JSON to a Powershell object
            $results = ($request.content | ConvertFrom-Json).content

            Write-Verbose "$Type with the ID $($results.id) has been created"

            Get-UnityiSCSIPortal -Session $Sess -Id $results.id
          } # End If ($request.StatusCode -eq $StatusCode)
        } # End If ($Sess.TestConnection()) 
    } # End Foreach ($sess in $session)
  } # End Process
} # End Function

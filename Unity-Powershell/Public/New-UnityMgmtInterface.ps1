Function New-UnityMgmtInterface {

  <#
      .SYNOPSIS
      Create a new network interface for managing the array.
      .DESCRIPTION
      Create a new network interface for managing the array.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specify an UnitySession Object.
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
      New-UnityMgmtInterface -ipAddress '192.0.2.1' -netmask '255.255.255.0' -gateway '192.0.2.254'

      Create a new network interface for managing the array.
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $true,Position = 1,HelpMessage = 'IPv4 or IPv6 address for the interface.')]
    [string]$ipAddress,
    [Parameter(Mandatory = $false,HelpMessage = 'IPv4 netmask for the interface, if the interface uses an IPv4 address.')]
    [string]$netmask,
    [Parameter(Mandatory = $false,HelpMessage = 'Prefix length in bits for IPv6 address.')]
    [String[]]$v6PrefixLength,
    [Parameter(Mandatory = $true,Position = 1,HelpMessage = 'IPv4 or IPv6 gateway address for the interface.')]
    [string]$gateway
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    ## Variables
    $URI = '/api/types/mgmtInterface/instances?timeout=0' #run async
    $Type = 'Management Interface'
    $StatusCode = 202
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      #### REQUEST BODY 

      #Creation of the body hash
      $body = @{}

      #Body arguments
      $body["ipAddress"] = $ipAddress
      $body["gateway"] = $gateway

      If ($PSBoundParameters.ContainsKey('netmask')) {
        $body["netmask"] = "$($netmask)"
      }

      If ($PSBoundParameters.ContainsKey('v6PrefixLength')) {
        $body["v6PrefixLength"] = "$($v6PrefixLength)"
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

          Write-Warning -Message 'You might be disconnected from the old interface'

        If ($pscmdlet.ShouldProcess($Sess.Name,"Create $Type $ipAddress")) {
          $request = Send-UnityRequest -uri $URI -Session $Sess -Method 'POST' -Body $Body
        }

        Write-Verbose "Request status code: $($request.StatusCode)"

        If ($request.StatusCode -eq $StatusCode) {
          Write-Host "Management interface is creating asynchronously."
        } # End If ($request.StatusCode -eq $StatusCode)
      } # End If ($Sess.TestConnection()) 
    } # End Foreach ($sess in $session)
  } # End Process
} # End Function

Function New-UnityFileInterface {

  <#
      .SYNOPSIS
      Creates a File Interface.
      .DESCRIPTION
      Creates a File Interface.
      These interfaces control access to Windows (CIFS) and UNIX/Linux (NFS) file storage.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specify an UnitySession Object.
      .PARAMETER nasServer
      ID of the NAS server to which the network interface belongs
      .PARAMETER ipPort
      Physical port or link aggregation on the storage processor on which the interface is running
      .PARAMETER ipAddress
      IP address of the network interface
      .PARAMETER netmask
      IPv4 netmask for the network interface, if it uses an IPv4 address
      .PARAMETER v6PrefixLength
      IPv6 prefix length for the interface, if it uses an IPv6 address
      .PARAMETER gateway
      IPv4 or IPv6 gateway address for the network interface
      .PARAMETER vlanId
      LAN identifier for the interface. The interface uses the identifier to accept packets that have matching VLAN tags. Values are 1 - 4094.
      .PARAMETER isPreferred
      Sets the current IP interface as preferred for associated for file-based storage and unsets the previous one
      .PARAMETER role
      Role of NAS server network interface
      .PARAMETER Confirm
      If the value is $true, indicates that the cmdlet asks for confirmation before running. 
      If the value is $false, the cmdlet runs without asking for user confirmation.
      .PARAMETER WhatIf
      Indicate that the cmdlet is run only to display the changes that would be made and actually no objects are modified.
      .EXAMPLE
      New-UnityFileInterface -ipPort spa_eth0 -nasServer nas_6 -ipAddress 192.168.0.1 -netmask 255.255.255.0 -gateway 192.168.0.254
      
      Create interface on the ethernet port 'spa_eth0' associated to the NAS server 'nas_6' 
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $true,Position = 1,HelpMessage = 'ID of the NAS server to which the network interface belongs')]
    $nasServer,
    [Parameter(Mandatory = $true,HelpMessage = 'Physical port or link aggregation on the storage processor on which the interface is running')]
    $ipPort,
    [Parameter(Mandatory = $true,HelpMessage = 'IP address of the network interface')]
    [ipaddress]$ipAddress,
    [Parameter(Mandatory = $false,HelpMessage = 'IPv4 netmask for the network interface, if it uses an IPv4 address')]
    [ipaddress]$netmask,
    [Parameter(Mandatory = $false,HelpMessage = 'IPv6 prefix length for the interface, if it uses an IPv6 address')]
    [String]$v6PrefixLength,
    [Parameter(Mandatory = $false,HelpMessage = 'IPv4 or IPv6 gateway address for the network interface')]
    [ipaddress]$gateway,
    [Parameter(Mandatory = $false,HelpMessage = ' VLAN identifier for the interface. The interface uses the identifier to accept packets that have matching VLAN tags. Values are 1 - 4094.')]
    [int]$vlanId,
    [Parameter(Mandatory = $false,HelpMessage = 'Sets the current IP interface as preferred for associated for file-based storage and unsets the previous one')]
    [bool]$isPreferred,
    [Parameter(Mandatory = $false,HelpMessage = 'Role of NAS server network interface')]
    [FileInterfaceRoleEnum]$role
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    # Variables
    $URI = '/api/types/fileInterface/instances'
    $Type = 'File Interface'
    $StatusCode = 201

  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      # Creation of the body hash
      $body = @{}

      # nasServer argument
      $body["nasServer"] = @{}
      $nasServerArg = @{}
      $nasServerArg["id"] = "$($nasServer)"
      $body["nasServer"] = $nasServerArg

      # ipPort argument
      $body["ipPort"] = @{}
      $ipPortArg = @{}
      $ipPortArg["id"] = "$($ipPort)"
      $body["ipPort"] = $ipPortArg

      # ipAddress argument
      $body["ipAddress"] = "$ipAddress"

      If ($PSBoundParameters.ContainsKey('netmask')) {
            $body["netmask"] = "$netmask"
      }

      If ($PSBoundParameters.ContainsKey('v6PrefixLength')) {
            $body["v6PrefixLength"] = "$v6PrefixLength"
      }

      If ($PSBoundParameters.ContainsKey('gateway')) {
            $body["gateway"] = "$gateway"
      }

      If ($PSBoundParameters.ContainsKey('vlanId')) {
            $body["vlanId"] = $vlanId
      }

      If ($PSBoundParameters.ContainsKey('isPreferred')) {
            $body["isPreferred"] = $isPreferred
      }

      If ($PSBoundParameters.ContainsKey('role')) {
            $body["role"] = "$role"
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
          If ($pscmdlet.ShouldProcess($Sess.Name,"Create $Type on $ipPort")) {
            $request = Send-UnityRequest -uri $URL -Session $Sess -Method 'POST' -Body $Body
          }

          Write-Verbose "Request status code: $($request.StatusCode)"

          If ($request.StatusCode -eq $StatusCode) {

            #Formating the result. Converting it from JSON to a Powershell object
            $results = ($request.content | ConvertFrom-Json).content

            Write-Verbose "$Type with the ID $($results.id) has been created"

            #Executing Get-UnityUser with the ID of the new user
            Get-UnityFileInterface -Session $Sess -ID $results.id
         } # End If ($request.StatusCode -eq $StatusCode)
      } # End If ($Sess.TestConnection()) 
    } # End Foreach ($sess in $session)
  } # End Process
} # End Function

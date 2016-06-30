Function New-UnityFileInterface {

  <#
      .SYNOPSIS
      Creates a File Interface.
      .DESCRIPTION
      Creates a NAS Server.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under Apache licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .EXAMPLE
      New-UnityFileInterface -Name 'POOL01' -virtualDisk -virtualDisk @{"id"='vdisk_1';"tier"='Performance'},@{"id"='vdisk_2';"tier"='Performance'}

      Create pool named 'POOL01' with virtual disks 'vdisk_1' and'vdisk_2'. Virtual disks are assigned to the performance tier. Apply to Unity VSA only.
  #>

  [CmdletBinding()]
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
    [String]$role
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"

    #Initialazing arrays
    $ResultCollection = @()

    $FileInterfaceRoleEnum = @{
      "Production" = "0"
      "Backup" = "1"
    }

  }

  Process {
    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

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
            $body["role"] = "$($FileInterfaceRoleEnum["$($role)"])"
      }

      If (Test-UnityConnection -Session $Sess) {

        #Building the URI
        $URI = 'https://'+$sess.Server+'/api/types/fileInterface/instances'
        Write-Verbose "URI: $URI"

        #Sending the request
        $request = Send-UnityRequest -uri $URI -Session $Sess -Method 'POST' -Body $Body

        Write-Verbose "Request status code: $($request.StatusCode)"

        If ($request.StatusCode -eq '201') {

          #Formating the result. Converting it from JSON to a Powershell object
          $results = ($request.content | ConvertFrom-Json).content

          Write-Verbose "File interface created with the ID: $($results.id) "

          #Executing Get-UnityUser with the ID of the new user
          Get-UnityFileInterface -Session $Sess -ID $results.id
        }
      } else {
        Write-Information -MessageData "You are no longer connected to EMC Unity array: $($Sess.Server)"
      }

    }
  }

  End {}
}

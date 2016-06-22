Function New-UnityNASServer {

  <#
      .SYNOPSIS
      Creates a NAS Server.
      .DESCRIPTION
      Create a NAS server. You can create a maximum of 24 NAS servers per system.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under Apache licence
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specify an UnitySession Object.
      .PARAMETER Name
      Specifies the NAS server name.
      NAS server names can contain alphanumeric characters, a single dash, and a single underscore. 
      Server names cannot contain spaces or begin or end with a dash. 
      You can create NAS server names in four parts that are separated by periods (example: aa.bb.cc.dd).
      Names can contain up to 255 characters, but the first part of the name (before the first period) is limited to 15 characters.
      .PARAMETER homeSP
      Specifies the parent SP for the NAS server.
      .PARAMETER Pool
      Specifies the ID of the storage pool for the NAS server.
      .PARAMETER isReplicationDestination
      Replication destination settings for the NAS server.
      When this option is set to yes, only mandatory parameters may be included. 
      All other optional parameters will be inherited from the source NAS server.
      Valid values are $true or $false (default).
      .PARAMETER UnixDirectoryService
      Directory Service used for querying identity information for Unix (such as UIDs, GIDs, net groups). Valid values are:
      - NIS
      - LDAP
      - None (Default)
      .PARAMETER isMultiProtocolEnabled
      Indicates whether multiprotocol sharing mode is enabled. Value is $true or $false (default).
      .PARAMETER allowUnmappedUser
      Use this flag to mandatorily disable access in case of any user mapping failure. Valide value are $true or $false (default).
      .PARAMETER defaultUnixUser
      Default Unix user name that grants file access in the multiprotocol sharing mode.
      This user name is used when the corresponding Unix/Linux user name is not found by the mapping mechanism.
      .PARAMETER defaultWindowsUser
      Default Windows user name that grants file access in the multiprotocol sharing mode. 
      This user name is used when the corresponding Windows user name is not found by the mapping mechanism.
      .EXAMPLE
      New-UnityNasServer -Name 'NAS01' -Pool 'pool_1' -homeSP 'spa'

      Create NAS server named 'NAS01' on the pool ID 'pool_1' and attached to the sp 'spa'
  #>

  [CmdletBinding()]
  Param (
    #Default Parameters
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $true,Position = 1,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Name for the NAS server')]

    #NasServer
    [String[]]$Name,
    [Parameter(Mandatory = $true,HelpMessage = 'Storage processor ID on which the NAS server will run')]
    $homeSP,
    [Parameter(Mandatory = $true,HelpMessage = 'A Storage pool ID that stores NAS server configuration information')]
    [String]$Pool,
    [Parameter(Mandatory = $false,HelpMessage = 'Indicates whether the NAS server is a replication destination')]
    [bool]$isReplicationDestination,
    [Parameter(Mandatory = $false,HelpMessage = 'Directory Service used for quering identity information for Unix')]
    [NasServerUnixDirectoryServiceEnum]$UnixDirectoryService,
    [Parameter(Mandatory = $false,HelpMessage = 'Indicates whether multiprotocol sharing mode is enabled')]
    [bool]$isMultiProtocolEnabled,
    [Parameter(Mandatory = $false,HelpMessage = 'Use this flag to mandatorily disable access in case of any user mapping failure')]
    [bool]$allowUnmappedUser,
    [Parameter(Mandatory = $false,HelpMessage = 'Default Unix user name used for granting access in case of Windows to Unix user mapping failure')]
    [String]$defaultUnixUser,
    [Parameter(Mandatory = $false,HelpMessage = 'Default Windows user name used for granting access in case of Unix to Windows user mapping failure. When empty, access in such case is denied')]
    [String]$defaultWindowsUser
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"

    #Initialazing arrays
    $ResultCollection = @()

  }

  Process {
    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      Foreach ($n in $Name) {

        # Creation of the body hash
        $body = @{}

        # Name parameter
        $body["name"] = "$($n)"

        # homeSP parameter
        $body["homeSP"] = @{}
        $homeSPParameters = @{}
        $homeSPParameters["id"] = "$($homeSP)"
        $body["homeSP"] = $homeSPParameters

        # Pool parameter
        $body["pool"] = @{}
        $poolParameters = @{}
        $poolParameters["id"] = "$($Pool)"
        $body["pool"] = $poolParameters

        If ($PSBoundParameters.ContainsKey('isReplicationDestination')) {
              $body["isReplicationDestination"] = $isReplicationDestination
        }

        If ($PSBoundParameters.ContainsKey('UnixDirectoryService')) {
              $body["currentUnixDirectoryService"] = $($UnixDirectoryService)
        }

        If ($PSBoundParameters.ContainsKey('isMultiProtocolEnabled')) {
              $body["isMultiProtocolEnabled"] = $isMultiProtocolEnabled
        }

        If ($PSBoundParameters.ContainsKey('allowUnmappedUser')) {
              $body["allowUnmappedUser"] = $allowUnmappedUser
        }

        If ($PSBoundParameters.ContainsKey('defaultUnixUser')) {
              $body["defaultUnixUser"] = $defaultUnixUser
        }

        If ($PSBoundParameters.ContainsKey('defaultWindowsUser')) {
              $body["defaultWindowsUser"] = $defaultWindowsUser
        }

        If (Test-UnityConnection -Session $Sess) {

          #Building the URI
          $URI = 'https://'+$sess.Server+'/api/types/nasServer/instances'
          Write-Verbose "URI: $URI"

          #Sending the request
          $request = Send-UnityRequest -uri $URI -Session $Sess -Method 'POST' -Body $Body

          Write-Verbose "Request status code: $($request.StatusCode)"

          If ($request.StatusCode -eq '201') {

            #Formating the result. Converting it from JSON to a Powershell object
            $results = ($request.content | ConvertFrom-Json).content

            Write-Verbose "NAS Server created with the ID: $($results.id) "

            #Executing Get-UnityUser with the ID of the new user
            Get-UnityNasServer -Session $Sess -ID $results.id
          }
        } else {
          Write-Warning "You are no longer connected to EMC Unity array: $($Sess.Server)"
        }
      }
    }
  }

  End {}
}

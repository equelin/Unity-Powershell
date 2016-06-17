Function New-UnityNASServer {

  <#
      .SYNOPSIS
      Creates a NAS Server.
      .DESCRIPTION
      Creates a NAS Server.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under Apache licence
      .LINK
      https://github.com/equelin/Unity-Powershell
      .EXAMPLE
      New-UnityNasServer -Name 'POOL01' -virtualDisk -virtualDisk @{"id"='vdisk_1';"tier"='Performance'},@{"id"='vdisk_2';"tier"='Performance'}

      Create pool named 'POOL01' with virtual disks 'vdisk_1' and'vdisk_2'. Virtual disks are assigned to the performance tier. Apply to Unity VSA only.
  #>

  [CmdletBinding()]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $true,Position = 1,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Name for the NAS server')]
    [String[]]$Name,
    [Parameter(Mandatory = $true,HelpMessage = 'Storage processor ID on which the NAS server will run')]
    $homeSP,
    [Parameter(Mandatory = $true,HelpMessage = 'A Storage pool ID that stores NAS server configuration information')]
    [String]$Pool,
    [Parameter(Mandatory = $false,HelpMessage = 'Indicates whether the NAS server is a replication destination')]
    [bool]$isReplicationDestination,
    [Parameter(Mandatory = $false,HelpMessage = 'Directory Service used for quering identity information for Unix')]
    $currentUnixDirectoryService,
    [Parameter(Mandatory = $false,HelpMessage = 'Indicates whether multiprotocol sharing mode is enabled')]
    [bool]$isMultiProtocolEnabled,
    [Parameter(Mandatory = $false,HelpMessage = 'Use this flag to mandatorily disable access in case of any user mapping failure')]
    [bool]$allowUnmappedUser,
    [Parameter(Mandatory = $false,HelpMessage = 'Default Unix user name used for granting access in case of Windows to Unix user mapping failure')]
    $defaultUnixUser,
    [Parameter(Mandatory = $false,HelpMessage = 'Default Windows user name used for granting access in case of Unix to Windows user mapping failure. When empty, access in such case is denied')]
    $defaultWindowsUser
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"

    #Initialazing arrays
    $ResultCollection = @()

    $NasServerUnixDirectoryService = @{
      "None" = "0"
      "NIS" = "2"
      "LDAP" = "3"
    }

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

        If ($PSBoundParameters.ContainsKey('currentUnixDirectoryService')) {
              $body["currentUnixDirectoryService"] = "$($NasServerUnixDirectoryService["$($currentUnixDirectoryService)"])"
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
          Write-Information -MessageData "You are no longer connected to EMC Unity array: $($Sess.Server)"
        }
      }
    }
  }

  End {}
}

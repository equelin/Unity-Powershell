Function Set-UnityNASServer {

  <#
      .SYNOPSIS
      Modifies NAS Server parameters.
      .DESCRIPTION
      Modifies NAS Server parameters.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under Apache licence
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specifies an UnitySession Object.
      .PARAMETER Name
      Specifies the NAS server name.
      .PARAMETER NewName
      Specifies the NAS server new name.
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
      Set-UnityNasServer -Name 'NAS01' -Description 'Modified description'

      Change the description of the NAS Server named NAS01
  #>

    [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    #Default Parameters
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),

    #NasServer
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Pool Name or Pool Object')]
    $Name,

    #NasServer Set parameters
    [Parameter(Mandatory = $false,HelpMessage = 'New Name of the Nas Server')]
    [String]$NewName,
    [Parameter(Mandatory = $false,HelpMessage = 'Storage processor ID on which the NAS server will run')]
    $homeSP,
    [Parameter(Mandatory = $false,HelpMessage = 'Indicates whether the NAS server is a replication destination')]
    [bool]$isReplicationDestination,
    [Parameter(Mandatory = $false,HelpMessage = 'Directory Service used for quering identity information for Unix')]
    [NasServerUnixDirectoryServiceEnum]$UnixDirectoryService,
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

    $NasServerUnixDirectoryService = @{
      "None" = "0"
      "NIS" = "2"
      "LDAP" = "3"
    }
  }

  Process {

    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If (Test-UnityConnection -Session $Sess) {

        Foreach ($n in $Name) {

          # Determine input and convert to UnityPool object
          Switch ($n.GetType().Name)
          {
            "String" {
              $NasServer = get-UnityNasServer -Session $Sess -Name $n
              $NasServerID = $NasServer.id
              $NasServerName = $NasServer.Name
            }
            "UnityPool" {
              Write-Verbose "Input object type is $($n.GetType().Name)"
              $NasServerName = $n.Name
              If ($NasServer = Get-UnityNasServer -Session $Sess -Name $NasServerName) {
                        $NasServerID = $n.id
              }
            }
          }

          If ($NasServerID) {

            # Creation of the body hash
            $body = @{}

            # Name parameter
            If ($NewName) {
              $body["name"] = "$($NewName)"
            }

            # homeSP parameter
            If ($PSBoundParameters.ContainsKey('homeSP')) {
              $body["homeSP"] = @{}
              $homeSPParameters = @{}
              $homeSPParameters["id"] = "$($homeSP)"
              $body["homeSP"] = $homeSPParameters
            }

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

            #Building the URI
            $URI = 'https://'+$sess.Server+'/api/instances/nasServer/'+$NasServerID+'/action/modify'
            Write-Verbose "URI: $URI"

            #Sending the request
            If ($pscmdlet.ShouldProcess($NasServerName,"Modify NAS Server")) {
              $request = Send-UnityRequest -uri $URI -Session $Sess -Method 'POST' -Body $Body
            }

            If ($request.StatusCode -eq '204') {

              Write-Verbose "Pool with ID: $NasServerID has been modified"

              Get-UnityNasServer -Session $Sess -id $NasServerID

            }
          } else {
            Write-Verbose "NAS Server $NasServerName does not exist on the array $($sess.Name)"
          }
        }
      } else {
        Write-Information -MessageData "You are no longer connected to EMC Unity array: $($Sess.Server)"
      }
    }
  }

  End {}
}

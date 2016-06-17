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
      .EXAMPLE
      Set-UnityNasServer -Name 'NAS01' -Description 'Modified description'

      Change the description of the NAS Server named NAS01
  #>

    [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Pool Name or Pool Object')]
    $Name,
    [Parameter(Mandatory = $false,HelpMessage = 'New Name of the Nas Server')]
    [String]$NewName,
    [Parameter(Mandatory = $false,HelpMessage = 'Storage processor ID on which the NAS server will run')]
    $homeSP,
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
    $defaultWindowsUser,
    [Parameter(Mandatory = $false,HelpMessage = 'Indicates whether a Unix to/from Windows user name mapping is enabled')]
    [bool]$enableWindowsToUnixUsernameMapping,
    [Parameter(Mandatory = $false,HelpMessage = 'Ignore warnings related to the operation')]
    [bool]$isIgnoreWarnings
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

            If ($PSBoundParameters.ContainsKey('enableWindowsToUnixUsernameMapping')) {
                  $body["enableWindowsToUnixUsernameMapping"] = $enableWindowsToUnixUsernameMapping
            }

            If ($PSBoundParameters.ContainsKey('isIgnoreWarnings')) {
                  $body["isIgnoreWarnings"] = $isIgnoreWarnings
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

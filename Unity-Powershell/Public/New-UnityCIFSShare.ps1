Function New-UnityCIFSShare {

  <#
      .SYNOPSIS
      Creates CIFS share.
      .DESCRIPTION
      Creates CIFS share.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under Apache licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .EXAMPLE
      New-UnityCIFSShare -Name 'FS01' -Description 'Modified description'

      Change the description of the filesystem named FS01
  #>

    [CmdletBinding()]
  Param (
    #Default Parameters
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    
    #SetFilesystem
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Filesystem Name')]
    [String[]]$Filesystem,

    #cifsShareCreate
    [Parameter(Mandatory = $false,HelpMessage = 'Local path to a location within a file system')]
    [String]$path,
    [Parameter(Mandatory = $true,HelpMessage = 'Name of the CIFS share unique to NAS server')]
    [String]$Name,
    [Parameter(Mandatory = $true,HelpMessage = 'CIFS server ID to use for CIFS share creation, as defined by the cifsServer type')]
    [String]$cifsServer,

    #$cifsShareParameters
    [Parameter(Mandatory = $false,HelpMessage = 'CIFS share description')]
    [String]$description,
    [Parameter(Mandatory = $false,HelpMessage = 'Indicates whether the CIFS share is read-only')]
    [bool]$isReadOnly,
    [Parameter(Mandatory = $false,HelpMessage = 'Indicates whether CIFS encryption for Server Message Block (SMB) 3.0 is enabled for the CIFS share')]
    [bool]$isEncryptionEnabled,
    [Parameter(Mandatory = $false,HelpMessage = 'Indicates whether continuous availability for SMB 3.0 is enabled for the CIFS share')]
    [bool]$isContinuousAvailabilityEnabled,
    [Parameter(Mandatory = $false,HelpMessage = 'Enumerate file with read access and directories with list access in folder listings')]
    [bool]$isABEEnabled,
    [Parameter(Mandatory = $false,HelpMessage = 'Branch Cache optimizes traffic between the NAS server and Branch Office Servers')]
    [bool]$isBranchCacheEnabled,
    [Parameter(Mandatory = $false,HelpMessage = 'Offline Files store a version of the shared resources on the client computer in the file system cache, a reserved portion of disk space, which the client computer can access even when it is disconnected from the network')]
    [CifsShareOfflineAvailabilityEnum]$offlineAvailability,
    [Parameter(Mandatory = $false,HelpMessage = 'The default UNIX umask for new files created on the share')]
    [String]$umask
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"
  }

  Process {

    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If (Test-UnityConnection -Session $Sess) {

        Foreach ($fs in $Filesystem) {

          # Determine input and convert to UnityFilesystem object
          Switch ($fs.GetType().Name)
          {
            "String" {
              $fs = get-UnityFilesystem -Session $Sess -Name $fs
              $filesystemID = $fs.id
              $filesystemName = $fs.Name
            }
            "UnityFilesystem" {
              Write-Verbose "Input object type is $($n.GetType().Name)"
              $filesystemName = $fs.Name
              If ($filesystem = Get-UnityFilesystem -Session $Sess -Name $fs) {
                        $filesystemID = $fs.id
              }
            }
          }

          If ($filesystemID) {

             $UnityStorageRessource = Get-UnitystorageResource -Session $sess | ? {($_.Name -like $filesystemName) -and ($_.filesystem.id -like $filesystemID)}

            # Creation of the body hash
            $body = @{}

            $body["cifsShareCreate"] = @()

              $cifsShareCreateParameters = @{}

              # path
              $cifsShareCreateParameters["path"] = "$($path)"

              # name
              $cifsShareCreateParameters["name"] = "$($name)"

              # cifsServer
              $cifsShareCreateParameters["cifsServer"] = @{}
                $cifsServerParameters = @{}
                $cifsServerParameters['id'] = "$($cifsServer)"
              $cifsShareCreateParameters["cifsServer"] = $cifsServerParameters
              
              #$cifsShareParameters
              If (($PSBoundParameters.ContainsKey('description')) -or ($PSBoundParameters.ContainsKey('isReadOnly')) -or ($PSBoundParameters.ContainsKey('isEncryptionEnabled')) -or ($PSBoundParameters.ContainsKey('isContinuousAvailabilityEnabled')) -or ($PSBoundParameters.ContainsKey('isABEEnabled')) -or ($PSBoundParameters.ContainsKey('isBranchCacheEnabled')) -or ($PSBoundParameters.ContainsKey('offlineAvailability')) -or ($PSBoundParameters.ContainsKey('umask'))){
                $cifsShareCreateParameters["cifsShareParameters"] = @{}
                
                $cifsShareParameters = @{}

                If ($PSBoundParameters.ContainsKey('description')) {
                  $cifsShareParameters["description"] = "$($description)"
                }

                If ($PSBoundParameters.ContainsKey('isReadOnly')) {
                  $cifsShareParameters["isReadOnly"] = $isReadOnly
                }

                If ($PSBoundParameters.ContainsKey('isEncryptionEnabled')) {
                  $cifsShareParameters["isEncryptionEnabled"] = $isEncryptionEnabled
                }

                If ($PSBoundParameters.ContainsKey('isContinuousAvailabilityEnabled')) {
                  $cifsShareParameters["isContinuousAvailabilityEnabled"] = $isContinuousAvailabilityEnabled
                }

                If ($PSBoundParameters.ContainsKey('isABEEnabled')) {
                  $cifsShareParameters["isABEEnabled"] = $isABEEnabled
                }

                If ($PSBoundParameters.ContainsKey('isBranchCacheEnabled')) {
                  $cifsShareParameters["isBranchCacheEnabled"] = $isBranchCacheEnabled
                }

                If ($PSBoundParameters.ContainsKey('offlineAvailability')) {
                  $cifsShareParameters["offlineAvailability"] = "$($offlineAvailability)"
                }

                If ($PSBoundParameters.ContainsKey('umask')) {
                  $cifsShareParameters["umask"] = "$($umask)"
                }

              $cifsShareCreateParameters["cifsShareParameters"] = $cifsShareParameters

              }

            $body["cifsShareCreate"] += $cifsShareCreateParameters

            #Building the URI
            $URI = 'https://'+$sess.Server+'/api/instances/storageResource/'+($UnityStorageRessource.id)+'/action/modifyFilesystem'
            Write-Verbose "URI: $URI"

            #Sending the request
            $request = Send-UnityRequest -uri $URI -Session $Sess -Method 'POST' -Body $Body

            If ($request.StatusCode -eq '204') {

              Write-Verbose "CIFS Share named $name on filesystem $filesystemName has been created"

              Get-UnityCIFSShare -Session $Sess -id $filesystemID

            }
          } else {
            Write-Verbose "filesystem $filesystemName does not exist on the array $($sess.Name)"
          }
        }
      } else {
        Write-Information -MessageData "You are no longer connected to EMC Unity array: $($Sess.Server)"
      }
    }
  }

  End {}
}

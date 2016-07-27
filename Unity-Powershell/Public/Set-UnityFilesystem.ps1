Function Set-UnityFilesystem {

  <#
      .SYNOPSIS
      Modifies filesystem parameters.
      .DESCRIPTION
      Modifies filesystem parameters.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under Apache licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .EXAMPLE
      Set-UnityFilesystem -Name 'FS01' -Description 'Modified description'

      Change the description of the filesystem named FS01
  #>

    [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    #Default Parameters
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    
    #SetFilesystem
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Filesystem Name')]
    [String[]]$Name,
    [Parameter(Mandatory = $false,HelpMessage = 'New Name of the filesystem')]
    [String]$NewName,
    [Parameter(Mandatory = $false,HelpMessage = 'Filesystem Description')]
    [String]$Description,
    [Parameter(Mandatory = $false,HelpMessage = 'ID of a protection schedule to apply to the filesystem')]
    [String]$snapSchedule,
    [Parameter(Mandatory = $false,HelpMessage = 'Is assigned snapshot schedule is paused ? (Default is false)')]
    [bool]$isSnapSchedulePaused = $false,
    
    #fsParameters
    [Parameter(Mandatory = $false,HelpMessage = 'Indicates whether to enable thin provisioning for file system')]
    [String]$isThinEnabled = $true,
    [Parameter(Mandatory = $false,HelpMessage = 'Filesystem Size in Bytes')]
    [String]$Size,
    [Parameter(Mandatory = $false,HelpMessage = 'Typical write I/O size from the host to the file system')]
    [HostIOSizeEnum]$hostIOSize,
    [Parameter(Mandatory = $false,HelpMessage = 'Indicates whether caching is disabled')]
    [bool]$isCacheDisabled,
    [Parameter(Mandatory = $false,HelpMessage = 'Access policy')]
    [AccessPolicyEnum]$accessPolicy,
    [Parameter(Mandatory = $false,HelpMessage = 'Behavior to follow when pool is full and a write to this filesystem is attempted')]
    [ResourcePoolFullPolicyEnum]$poolFullPolicy,

    ##fastVPParameterseters
    [Parameter(Mandatory = $false,HelpMessage = 'Filesystem tiering policy')]
    [TieringPolicyEnum]$tieringPolicy,
    
    #cifsFilesystemParameters
    [Parameter(Mandatory = $false,HelpMessage = 'Indicates whether the CIFS synchronous writes option is enabled for the file system')]
    [bool]$isCIFSSyncWritesEnabled,
    [Parameter(Mandatory = $false,HelpMessage = 'Indicates whether opportunistic file locks are enabled for the file system')]
    [bool]$isCIFSOpLocksEnabled,
    [Parameter(Mandatory = $false,HelpMessage = 'Indicates whether the system generates a notification when the file system is written to')]
    [bool]$isCIFSNotifyOnWriteEnabled,
    [Parameter(Mandatory = $false,HelpMessage = 'Indicates whether the system generates a notification when a user accesses the file system')]
    [bool]$isCIFSNotifyOnAccessEnabled,
    [Parameter(Mandatory = $false,HelpMessage = 'Indicates the lowest directory level to which the enabled notifications apply, if any')]
    [int]$cifsNotifyOnChangeDirDepth
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"
  }

  Process {

    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If ($Sess.TestConnection()) {

        Foreach ($n in $Name) {

          # Determine input and convert to UnityFilesystem object
          Switch ($n.GetType().Name)
          {
            "String" {
              $filesystem = get-UnityFilesystem -Session $Sess -Name $n
              $filesystemID = $filesystem.id
              $filesystemName = $filesystem.Name
            }
            "UnityFilesystem" {
              Write-Verbose "Input object type is $($n.GetType().Name)"
              $filesystemName = $n.Name
              If ($filesystem = Get-UnityFilesystem -Session $Sess -Name $filesystemName) {
                        $filesystemID = $n.id
              }
            }
          }

          If ($filesystemID) {

             $UnityStorageRessource = Get-UnitystorageResource -Session $sess | ? {($_.Name -like $filesystemName) -and ($_.filesystem.id -like $filesystemID)}

            # Creation of the body hash
            $body = @{}

            # Name parameter
            If ($NewName) {
              $body["name"] = "$($NewName)"
            }

            # Domain parameter
            If ($Description) {
                  $body["description"] = "$($Description)"
            }

            If (($PSBoundParameters.ContainsKey('Size')) -or ($PSBoundParameters.ContainsKey('isThinEnabled')) -or ($PSBoundParameters.ContainsKey('hostIOSize')) -or ($PSBoundParameters.ContainsKey('tieringPolicy')) -or ($PSBoundParameters.ContainsKey('isCacheDisabled')) -or ($PSBoundParameters.ContainsKey('accessPolicy')) -or ($PSBoundParameters.ContainsKey('poolFullPolicy'))) {
              # fsParameters parameter
              $body["fsParameters"] = @{}
                $fsParameters = @{}
                
                # Size
                If ($PSBoundParameters.ContainsKey('Size')) {
                  $fsParameters["Size"] = $Size
                }
              
                # isThinEnabled
                If ($PSBoundParameters.ContainsKey('isThinEnabled')) {
                  $fsParameters["isThinEnabled"] = $isThinEnabled
                }

                # hostIOSize
                If ($PSBoundParameters.ContainsKey('hostIOSize')) {
                  $fsParameters["hostIOSize"] = $hostIOSize
                }

                # fastVPParameters
                If ($PSBoundParameters.ContainsKey('tieringPolicy')) {
                  $fastVPParameters = @{}
                  $fastVPParameters['tieringPolicy'] = $tieringPolicy
                  $fsParameters["fastVPParameters"] = $fastVPParameters
                }

                # isCacheDisabled
                If ($PSBoundParameters.ContainsKey('isCacheDisabled')) {
                  $fsParameters["isThinEnabled"] = $isCacheDisabled
                }

                # accessPolicy
                If ($PSBoundParameters.ContainsKey('accessPolicy')) {
                  $fsParameters["accessPolicy"] = $accessPolicy
                }

                # poolFullPolicy
                If ($PSBoundParameters.ContainsKey('poolFullPolicy')) {
                  $fsParameters["poolFullPolicy"] = $poolFullPolicy
                }

              $body["fsParameters"] = $fsParameters
            }


            If (($PSBoundParameters.ContainsKey('isCIFSSyncWritesEnabled')) -or ($PSBoundParameters.ContainsKey('isCIFSOpLocksEnabled')) -or ($PSBoundParameters.ContainsKey('isCIFSNotifyOnWriteEnabled')) -or ($PSBoundParameters.ContainsKey('isCIFSNotifyOnAccessEnabled')) -or ($PSBoundParameters.ContainsKey('cifsNotifyOnChangeDirDepth'))) {
              $body["cifsFsParameters"] = @{}
              $cifsFsParameters = @{}

              # isCIFSSyncWritesEnabled
              If ($PSBoundParameters.ContainsKey('isCIFSSyncWritesEnabled')) {
                $fsParameters["isCIFSSyncWritesEnabled"] = $isCIFSSyncWritesEnabled
              }
              
              # isCIFSOpLocksEnabled
              If ($PSBoundParameters.ContainsKey('isCIFSOpLocksEnabled')) {
                $fsParameters["isCIFSOpLocksEnabled"] = $isCIFSOpLocksEnabled
              }
              # isCIFSNotifyOnWriteEnabled
              If ($PSBoundParameters.ContainsKey('isCIFSNotifyOnWriteEnabled')) {
                $fsParameters["isCIFSNotifyOnWriteEnabled"] = $isCIFSNotifyOnWriteEnabled
              }
              # isCIFSNotifyOnAccessEnabled
              If ($PSBoundParameters.ContainsKey('isCIFSNotifyOnAccessEnabled')) {
                $fsParameters["isCIFSNotifyOnAccessEnabled"] = $isCIFSNotifyOnAccessEnabled
              }
              # cifsNotifyOnChangeDirDepth
              If ($PSBoundParameters.ContainsKey('cifsNotifyOnChangeDirDepth')) {
                $fsParameters["cifsNotifyOnChangeDirDepth"] = $cifsNotifyOnChangeDirDepth
              }
              
            $body["cifsFsParameters"] = $cifsFsParameters
            }
            
            #snapScheduleParameters
            If ($snapSchedule) {
              $body["snapScheduleParameters"] = @{}
              $snapScheduleParameters = @{}
              $snapScheduleParam = @{}
              $snapScheduleParam["id"] ="$($snapSchedule)"
              $snapScheduleParameters["snapSchedule"] = $snapScheduleParam
              $snapScheduleParameters["isSnapSchedulePaused"]= "$($isSnapSchedulePaused)"
              $body["snapScheduleParameters"] = $snapScheduleParameters
            }

            #Building the URI
            $URI = 'https://'+$sess.Server+'/api/instances/storageResource/'+($UnityStorageRessource.id)+'/action/modifyFilesystem'
            Write-Verbose "URI: $URI"

            #Sending the request
            If ($pscmdlet.ShouldProcess($filesystemName,"Modify filesystem")) {
              $request = Send-UnityRequest -uri $URI -Session $Sess -Method 'POST' -Body $Body
            }

            If ($request.StatusCode -eq '204') {

              Write-Verbose "Filesystem with ID: $filesystemID has been modified"

              Get-UnityFilesystem -Session $Sess -id $filesystemID

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

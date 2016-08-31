Function New-UnityFilesystem {

  <#
      .SYNOPSIS
      Creates a Unity Filesystem.
      .DESCRIPTION
      Creates a Unity Filesystem.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .EXAMPLE
      New-UnityFilesystem -Name 'FS01' -Pool 'pool_1' -Size 3298534883328 -nasServer 'nas_1' -supportedProtocols 'CIFS'

      Create CIFS filesystem named 'FS01' on pool 'pool_1' and with a size of '3298534883328' bytes
  #>

  [CmdletBinding()]
  Param (
    
    #Default Parameters
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),

    #CreateFilesystem
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Filesystem Name')]
    [String[]]$Name,
    [Parameter(Mandatory = $false,HelpMessage = 'Filesystem Description')]
    [String]$Description,
    [Parameter(Mandatory = $false,HelpMessage = 'ID of a protection schedule to apply to the filesystem')]
    [String]$snapSchedule,
    [Parameter(Mandatory = $false,HelpMessage = 'Is assigned snapshot schedule is paused ? (Default is false)')]
    [bool]$isSnapSchedulePaused = $false,
    
    #fsParameters
    [Parameter(Mandatory = $true,HelpMessage = 'Filesystem Pool ID')]
    [String]$Pool,
    [Parameter(Mandatory = $true,HelpMessage = 'Filesystem nasServer')]
    [String]$nasServer,
    [Parameter(Mandatory = $true,HelpMessage = 'Filesystem supported protocols')]
    [FSSupportedProtocolEnum]$supportedProtocols,
    [Parameter(Mandatory = $false,HelpMessage = 'Indicates whether File Level Retention (FLR) is enabled for the file system')]
    [String]$isFLREnabled = $false,
    [Parameter(Mandatory = $false,HelpMessage = 'Indicates whether to enable thin provisioning for file system')]
    [String]$isThinEnabled = $true,
    [Parameter(Mandatory = $true,HelpMessage = 'Filesystem Size in Bytes')]
    [uint64]$Size,
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

      Foreach ($n in $Name) {

        # Creation of the body hash
        $body = @{}

        # Name parameter
        $body["name"] = "$($n)"

        # Domain parameter
        If ($Description) {
              $body["description"] = "$($Description)"
        }

        # fsParameters parameter
        $body["fsParameters"] = @{}
          $fsParameters = @{}
            $poolParameters = @{}
            $poolParameters["id"] = "$($Pool)"
          $fsParameters["pool"] = $poolParameters
        
          $nasServerParameters = @{}
            $nasServerParameters["id"] = "$($nasServer)"
          $fsParameters["nasServer"] = $nasServerParameters

          $fsParameters["size"] = $($Size)
          
          $fsParameters["supportedProtocols"] = $($supportedProtocols)
          
          # isFLREnabled
          If ($PSBoundParameters.ContainsKey('isFLREnabled')) {
            $fsParameters["isFLREnabled"] = $isFLREnabled
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

        IF (($PSBoundParameters.ContainsKey('isCIFSSyncWritesEnabled')) -or ($PSBoundParameters.ContainsKey('isCIFSOpLocksEnabled')) -or ($PSBoundParameters.ContainsKey('isCIFSNotifyOnWriteEnabled')) -or ($PSBoundParameters.ContainsKey('isCIFSNotifyOnAccessEnabled')) -or ($PSBoundParameters.ContainsKey('cifsNotifyOnChangeDirDepth'))) {
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

        If ($Sess.TestConnection()) {

          #Building the URI
          $URI = 'https://'+$sess.Server+'/api/types/storageResource/action/createFilesystem'
          Write-Verbose "URI: $URI"

          #Sending the request
          $request = Send-UnityRequest -uri $URI -Session $Sess -Method 'POST' -Body $Body

          Write-Verbose "Request status code: $($request.StatusCode)"

          If ($request.StatusCode -eq '200') {

            #Formating the result. Converting it from JSON to a Powershell object
            $results = ($request.content | ConvertFrom-Json).content.storageResource

            Write-Verbose "Filesystem created with the storage resource ID: $($results.id) "

            #Executing Get-UnityFilesystem with the ID of the new user
            Get-UnityFilesystem -Session $Sess -Name $n
          }
        } else {
          Write-Information -MessageData "You are no longer connected to EMC Unity array: $($Sess.Server)"
        }
      }
    }
  }

  End {
  }
}

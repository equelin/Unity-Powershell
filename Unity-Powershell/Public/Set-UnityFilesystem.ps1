Function Set-UnityFilesystem {

  <#
      .SYNOPSIS
      Modifies filesystem parameters.
      .DESCRIPTION
      Modifies filesystem parameters.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specify an UnitySession Object.
      .PARAMETER Name
      New Name of the filesystem
      .PARAMETER Description
      Filesystem Description
      .PARAMETER snapSchedule
      ID of a protection schedule to apply to the filesystem
      .PARAMETER isSnapSchedulePaused
      Is assigned snapshot schedule is paused ? (Default is false)
      .PARAMETER isThinEnabled
      Indicates whether to enable thin provisioning for file system. Default is $True
      .PARAMETER Size
      Filesystem Size
      .PARAMETER hostIOSize
      Typical write I/O size from the host to the file system
      .PARAMETER isCacheDisabled
      Indicates whether caching is disabled
      .PARAMETER accessPolicy
      Access policy
      .PARAMETER poolFullPolicy
      Behavior to follow when pool is full and a write to this filesystem is attempted
      .PARAMETER tieringPolicy
      Filesystem tiering policy
      .PARAMETER isCIFSSyncWritesEnabled
      Indicates whether the CIFS synchronous writes option is enabled for the file system
      .PARAMETER isCIFSOpLocksEnabled
      Indicates whether opportunistic file locks are enabled for the file system
      .PARAMETER isCIFSNotifyOnWriteEnabled
      Indicates whether the system generates a notification when the file system is written to
      .PARAMETER isCIFSNotifyOnAccessEnabled
      Indicates whether the system generates a notification when a user accesses the file system
      .PARAMETER cifsNotifyOnChangeDirDepth
      Indicates the lowest directory level to which the enabled notifications apply, if any
      .PARAMETER Confirm
      If the value is $true, indicates that the cmdlet asks for confirmation before running. If the value is $false, the cmdlet runs without asking for user confirmation.
      .PARAMETER WhatIf
      Indicate that the cmdlet is run only to display the changes that would be made and actually no objects are modified.
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
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Filesystem ID or Object')]
    [Object[]]$ID,
    [Parameter(Mandatory = $false,HelpMessage = 'New Name of the filesystem')]
    [String]$Name,
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
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    # Variables
    $URI = '/api/instances/storageResource/<id>/action/modifyFilesystem'
    $Type = 'Filesystem'
    $TypeName = 'UnityFilesystem'
    $StatusCode = 204
  }

  Process {

    Foreach ($sess in $session) {

      Write-Debug -Message "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If ($Sess.TestConnection()) {

        Foreach ($i in $ID) {

          # Determine input and convert to object if necessary
          $Object,$ObjectID,$ObjectName = Get-UnityObject -Data $i -Typename $Typename -Session $Sess

          If ($ObjectID) {

            $UnitystorageResource = Get-UnitystorageResource -Session $sess | Where-Object {($_.filesystem.id -like $ObjectID)}

            #### REQUEST BODY

            # Creation of the body hash
            $body = @{}

            # Name parameter
            If ($NewName) {
              $body["name"] = "$($Name)"
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

            ####### END BODY - Do not edit beyond this line

            #Show $body in verbose message
            $Json = $body | ConvertTo-Json -Depth 10
            Write-Verbose $Json 

            #Building the URL
            $FinalURI = $URI -replace '<id>',$UnitystorageResource.id

            $URL = 'https://'+$sess.Server+$FinalURI
            Write-Verbose "URL: $URL"

            #Sending the request
            If ($pscmdlet.ShouldProcess($Sess.Name,"Modify $Type $ObjectName")) {
              $request = Send-UnityRequest -uri $URL -Session $Sess -Method 'POST' -Body $Body
            }
            
            If ($request.StatusCode -eq $StatusCode) {

              Write-Verbose "$Type with ID $ObjectID has been modified"

              Get-UnityFilesystem  -Session $Sess -ID $ObjectID

            }  # End If ($request.StatusCode -eq $StatusCode)
          } else {
            Write-Warning -Message "$Type with ID $i does not exist on the array $($sess.Name)"
          } # End If ($ObjectID)
        } # End Foreach ($i in $ID)
      } # End If ($Sess.TestConnection()) 
    } # End Foreach ($sess in $session)
  } # End Process
} # End Function

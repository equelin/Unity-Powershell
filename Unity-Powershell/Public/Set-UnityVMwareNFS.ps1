Function Set-UnityVMwareNFS {

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
      .PARAMETER Size
      Filesystem Size
      .PARAMETER hostIOSize
      Typical write I/O size from the host to the file system
      .PARAMETER tieringPolicy
      Filesystem tiering policy
      .PARAMETER defaultAccess
      Default access level for all hosts accessing the VMware NFS LUN.
      .PARAMETER noAccessHosts
      Hosts with no access to the VMware NFS LUN or its snapshots, as defined by the host resource type.
      .PARAMETER readOnlyHosts
      Hosts with read-only access to the VMware NFS LUN and its snapshots, as defined by the host resource type.
      .PARAMETER readWriteHosts
      Hosts with read-write access to the VMware NFS LUN and its snapshots, as defined by the host resource type.
      .PARAMETER rootAccessHosts
      Hosts with root access to the VMware NFS LUN and its snapshots, as defined by the host resource type.
      .PARAMETER Append
      Append Hosts access to existing configuration
      .PARAMETER Confirm
      If the value is $true, indicates that the cmdlet asks for confirmation before running. If the value is $false, the cmdlet runs without asking for user confirmation.
      .PARAMETER WhatIf
      Indicate that the cmdlet is run only to display the changes that would be made and actually no objects are modified.
      .EXAMPLE
      Set-UnityVMwareNFS -ID 'fs_1' -Description 'Modified description'

      Change the description of the VMware NFS LUN named FS01
  #>

    [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    #Default Parameters
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    
    #SetFilesystem
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'VMware NFS LUN ID or Object')]
    [Object[]]$ID,
    [Parameter(Mandatory = $false,HelpMessage = 'Filesystem Description')]
    [String]$Description,
    [Parameter(Mandatory = $false,HelpMessage = 'ID of a protection schedule to apply to the VMware NFS LUN')]
    [String]$snapSchedule,
    [Parameter(Mandatory = $false,HelpMessage = 'Is assigned snapshot schedule is paused ? (Default is false)')]
    [bool]$isSnapSchedulePaused = $false,
    
    #fsParameters
    [Parameter(Mandatory = $false,HelpMessage = 'VMware NFS LUN Size in Bytes')]
    [uint64]$Size,
    [Parameter(Mandatory = $false,HelpMessage = 'Typical write I/O size from the host to the file system')]
    [HostIOSizeEnum]$hostIOSize,

    ##fastVPParameters
    [Parameter(Mandatory = $false,HelpMessage = 'VMware NFS LUN tiering policy')]
    [TieringPolicyEnum]$tieringPolicy,

    #$nfsShareParameters
    [Parameter(Mandatory = $false,HelpMessage = 'Default access level for all hosts accessing the VMware NFS LUN.')]
    [NFSShareDefaultAccessEnum]$defaultAccess,
    [Parameter(Mandatory = $false,HelpMessage = 'Hosts with no access to the VMware NFS LUN or its snapshots.')]
    [string[]]$noAccessHosts,
    [Parameter(Mandatory = $false,HelpMessage = 'Hosts with read-only access to the VMware NFS LUN and its snapshots.')]
    [string[]]$readOnlyHosts,
    [Parameter(Mandatory = $false,HelpMessage = 'Hosts with read-write access to the VMware NFS LUN and its snapshots.')]
    [string[]]$readWriteHosts,
    [Parameter(Mandatory = $false,HelpMessage = 'Hosts with root access to the VMware NFS LUN and its snapshots.')]
    [string[]]$rootAccessHosts,
    [Parameter(Mandatory = $false,HelpMessage = 'Append Hosts access to existing configuration')]
    [Switch]$append
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    # Variables
    $URI = '/api/instances/storageResource/<id>/action/modifyVmwareNfs'
    $Type = 'VMware NFS LUN'
    $TypeName = 'UnityFilesystem'
    $StatusCode = 204
  }

  Process {

    Foreach ($sess in $session) {

      Write-Debug -Message "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If ($Sess.TestConnection()) {

        Foreach ($i in $ID) {

          # Determine input and convert to object if necessary
          $Object,$ObjectID,$ObjectName = Get-UnityObject -Data $i -Typename $Typename -Command 'UnityVMwareNFS' -Session $Sess

          If ($ObjectID) {

            $UnitystorageResource = Get-UnitystorageResource -Session $sess | Where-Object {($_.filesystem.id -like $ObjectID)}

            $NFSShare = Get-UnityNFSShare -Session $Sess -ID $Object.NfsShare.id

            #### REQUEST BODY

            # Creation of the body hash
            $body = @{}

            # Description parameter
            If ($Description) {
                  $body["description"] = "$($Description)"
            }

            If (($PSBoundParameters.ContainsKey('Size')) -or ($PSBoundParameters.ContainsKey('hostIOSize')) -or ($PSBoundParameters.ContainsKey('tieringPolicy'))) {
              # fsParameters parameter
              $body["fsParameters"] = @{}
                $fsParameters = @{}
                
                # Size
                If ($PSBoundParameters.ContainsKey('Size')) {
                  $fsParameters["Size"] = $Size
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

              $body["fsParameters"] = $fsParameters
            }

            #$nfsShareParameters
            
              
            $nfsShareParameters = @{}

            If ($PSBoundParameters.ContainsKey('defaultAccess')) {
              $nfsShareParameters["defaultAccess"] = $defaultAccess
            }

            If ($PSBoundParameters.ContainsKey('noAccessHosts')) {
            
              $nfsShareParameters["noAccessHosts"] = @()

              foreach ($h in $noAccessHosts) {

                    $HostParam = @{}
                    $HostParam['id'] = $h

                    $nfsShareParameters["noAccessHosts"] += $HostParam
              }

              If ($append) {
                foreach ($h in $NFSShare.noAccessHosts) {
                  $nfsShareParameters["noAccessHosts"] += $h
                }
              } 
            }

            If ($PSBoundParameters.ContainsKey('readOnlyHosts')) {
            
              $nfsShareParameters["readOnlyHosts"] = @()

              foreach ($h in $readOnlyHosts) {

                    $HostParam = @{}
                    $HostParam['id'] = $h

                $nfsShareParameters["readOnlyHosts"] += $HostParam
              }
        
              If ($append) {
                foreach ($h in $NFSShare.readOnlyHosts) {
                  $nfsShareParameters["readOnlyHosts"] += $h
                }
              } 
            }

            If ($PSBoundParameters.ContainsKey('readWriteHosts')) {
            
              $nfsShareParameters["readWriteHosts"] = @()

              foreach ($h in $readWriteHosts) {

                    $HostParam = @{}
                    $HostParam['id'] = $h

                $nfsShareParameters["readWriteHosts"] += $HostParam
              }
        
              If ($append) {
                foreach ($h in $NFSShare.readWriteHosts) {
                  $nfsShareParameters["readWriteHosts"] += $h
                }
              } 
            }

            If ($PSBoundParameters.ContainsKey('rootAccessHosts')) {
            
              $nfsShareParameters["rootAccessHosts"] = @()

              foreach ($h in $rootAccessHosts) {

                    $HostParam = @{}
                    $HostParam['id'] = $h

                $nfsShareParameters["rootAccessHosts"] += $HostParam
              }
        
              If ($append) {
                foreach ($h in $NFSShare.rootAccessHosts) {
                  $nfsShareParameters["rootAccessHosts"] += $h
                }
              } 
            }

            If ($nfsShareParameters.count) {
              $body["nfsShareParameters"] = @{}
              $body["nfsShareParameters"] = $nfsShareParameters
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

              Get-UnityVMwareNFS  -Session $Sess -ID $ObjectID

            }  # End If ($request.StatusCode -eq $StatusCode)
          } else {
            Write-Warning -Message "$Type with ID $i does not exist on the array $($sess.Name)"
          } # End If ($ObjectID)
        } # End Foreach ($i in $ID)
      } # End If ($Sess.TestConnection()) 
    } # End Foreach ($sess in $session)
  } # End Process
} # End Function

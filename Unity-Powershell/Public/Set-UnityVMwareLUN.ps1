Function Set-UnityVMwareLUN {

  <#
      .SYNOPSIS
      Modifies VMware block LUN parameters.
      .DESCRIPTION
      Modifies VMware block LUN parameters.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specify an UnitySession Object.
      .PARAMETER Confirm
      If the value is $true, indicates that the cmdlet asks for confirmation before running. 
      If the value is $false, the cmdlet runs without asking for user confirmation.
      .PARAMETER WhatIf
      Indicate that the cmdlet is run only to display the changes that would be made and actually no objects are modified.
      .PARAMETER ID
      ID or Object.
      .PARAMETER Name
      New name of the VMware VMFS datastore unique to the system.
      .PARAMETER Description
      New description of the VMware VMFS datastore.
      .PARAMETER Size
      New LUN size. The size parameter can be greater than the current LUN size in this case the LUN is expanded.
      .PARAMETER fastVPParameters
      FAST VP settings for the storage resource
      .PARAMETER isCompressionEnabled
      Indicates whether to enable inline compression for the LUN. Default is True
      .PARAMETER snapSchedule
      Snapshot schedule settings for the VMware VMFS datastore, as defined by the snapScheduleParameters.
      .PARAMETER host
      List of host to grant access to LUN.
      .PARAMETER accessMask
      Host access mask. Might be:
      - NoAccess: No access. 
      - Production: Access to production LUNs only. 
      - Snapshot: Access to LUN snapshots only. 
      - Both: Access to both production LUNs and their snapshots. 
      .PARAMETER append
      Add new host access to the existing configuration.
      .PARAMETER snapSchedule
      Snapshot schedule assigned to the storage resource 
      .PARAMETER isSnapSchedulePaused
      Indicates whether the assigned snapshot schedule is paused.
      .EXAMPLE
      Set-UnityVMwareLUN -ID 'sv_78' -Description 'Modified description'

      Change the description of the VMware bock LUN with ID 'sv_78'.
      .EXAMPLE
      Set-UnityVMwareLUN -ID 'sv_78' -Pool 'pool_14' -host 'Host_12' -accessMask 'Production' -Append

      Grant 'production' access to host 'Host_12' to VMware bock LUN with ID 'sv_78'.
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'LUN ID or LUN Object')]
    [Object[]]$ID,
    [Parameter(Mandatory = $false,HelpMessage = 'New Name of the LUN')]
    [String]$Name,
    [Parameter(Mandatory = $false,HelpMessage = 'New LUN Description')]
    [String]$Description,

    # lunParameters
    [Parameter(Mandatory = $false,HelpMessage = 'New LUN Size in Bytes')]
    [uint64]$Size,
    [Parameter(Mandatory = $false,HelpMessage = 'FAST VP settings for the storage resource')]
    [TieringPolicyEnum]$fastVPParameters,
    [Parameter(Mandatory = $false,HelpMessage = 'Indicates whether to enable inline compression for the LUN. Default is True')]
    [bool]$isCompressionEnabled,
    
    # snapScheduleParameters
    [Parameter(Mandatory = $false,HelpMessage = 'ID of a protection schedule to apply to the storage resource')]
    [String]$snapSchedule,
    [Parameter(Mandatory = $false,HelpMessage = 'Is assigned snapshot schedule is paused ? (Default is false)')]
    [bool]$isSnapSchedulePaused = $false,

    # hostParameters
    [Parameter(Mandatory = $false,HelpMessage = 'Host to grant access to LUN')]
    [String[]]$host,
    [Parameter(Mandatory = $false,HelpMessage = 'Append Host access to existing configuration')]
    [Switch]$append,
    [Parameter(Mandatory = $false,HelpMessage = 'Host access mask')]
    [HostLUNAccessEnum]$accessMask = 'Production'
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    # Variables
    $URI = '/api/instances/storageResource/<id>/action/modifyVmwareLun'
    $Type = 'VMware LUN'
    $TypeName = 'UnityVMwareLUN'
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

            $UnitystorageResource = Get-UnityStorageResource -Session $sess | Where-Object {($_.Name -like $ObjectName) -and ($_.luns.id -like $ObjectID)}

            # Creation of the body hash
            $body = @{}

            # Name parameter
            If ($PSBoundParameters.ContainsKey('Name')) {
              $body["name"] = $Name
            }

            # Description parameter
            If ($PSBoundParameters.ContainsKey('description')) {
              $body["description"] = $Description
            }

            # lunParameters parameter
            If (($PSBoundParameters.ContainsKey('size')) -or ($PSBoundParameters.ContainsKey('host')) -or ($PSBoundParameters.ContainsKey('fastVPParameters')) -or ($PSBoundParameters.ContainsKey('isCompressionEnabled'))) {
              $body["lunParameters"] = @{}
              $lunParameters = @{}
            
              If ($PSBoundParameters.ContainsKey('Size')) {
                $lunParameters["size"] = $($Size)
              }

              If ($PSBoundParameters.ContainsKey('fastVPParameters')) {
                $lunParameters["fastVPParameters"] = @{}
                $fastVPParam = @{}
                $fastVPParam['tieringPolicy'] = $fastVPParameters
                $lunParameters["fastVPParameters"] = $fastVPParam
              }

              If ($PSBoundParameters.ContainsKey('isCompressionEnabled')) {
                $lunParameters["isCompressionEnabled"] = $isCompressionEnabled
              }

              If ($PSBoundParameters.ContainsKey('host')) {
              
                $lunParameters["hostAccess"] = @()
                $hostAccess = @()

                foreach ($h in $host) {
                  $blockHostAccessParam = @{}
                    $blockHostAccessParam['host'] = @{}
                      $HostParam = @{}
                      $HostParam['id'] = $h
                    $blockHostAccessParam['host'] = $HostParam
                    $blockHostAccessParam['accessMask'] = $accessMask
                  $hostAccess += $blockHostAccessParam
                }

                If ($PSBoundParameters.ContainsKey('append')) {

                  foreach ($h in $Object.hostAccess) {

                    if (-not ($hostAccess.host.id -contains $h.host.id)) {
                      $blockHostAccessParam = @{}
                      $blockHostAccessParam['host'] = @{}
                        $HostParam = @{}
                        $HostParam['id'] = $h.host.id
                      $blockHostAccessParam['host'] = $HostParam
                      $blockHostAccessParam['accessMask'] = $h.accessMask
                      $hostAccess += $blockHostAccessParam
                    }
                  }
                } else {
                  Write-Warning -Message 'The existing host access parameters will be overwritten by the new settings. It could result to data unavailibility. Use the -Append parameter to add the new settings to the existing configuration.'
                }

                $lunParameters["hostAccess"] = $hostAccess
          
              }
            
              $body["lunParameters"] = $lunParameters
      
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

              Get-UnityVMwareLUN -Session $Sess -ID $ObjectID

            }  # End If ($request.StatusCode -eq $StatusCode)
          } else {
            Write-Warning -Message "$Type with ID $i does not exist on the array $($sess.Name)"
          } # End If ($ObjectID)
        } # End Foreach ($i in $ID)
      } # End If ($Sess.TestConnection()) 
    } # End Foreach ($sess in $session)
  } # End Process
} # End Function

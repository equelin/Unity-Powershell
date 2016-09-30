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
    $ID,
    [Parameter(Mandatory = $false,HelpMessage = 'New Name of the LUN')]
    [String]$Name,
    [Parameter(Mandatory = $false,HelpMessage = 'New LUN Description')]
    [String]$Description,
    [Parameter(Mandatory = $false,HelpMessage = 'New LUN Size in Bytes')]
    [uint64]$Size,
    [Parameter(Mandatory = $false,HelpMessage = 'ID of a protection schedule to apply to the storage resource')]
    [String]$snapSchedule,
    [Parameter(Mandatory = $false,HelpMessage = 'Host to grant access to LUN')]
    [String[]]$host,
    [Parameter(Mandatory = $false,HelpMessage = 'Append Host access to existing configuration')]
    [Switch]$append,
    [Parameter(Mandatory = $false,HelpMessage = 'Host access mask')]
    [HostLUNAccessEnum]$accessMask = 'Production',
    [Parameter(Mandatory = $false,HelpMessage = 'Is assigned snapshot schedule is paused ? (Default is false)')]
    [bool]$isSnapSchedulePaused = $false
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"

    # Variables
    $URI = '/api/instances/storageResource/<id>/action/modifyVmwareLun'
    $Type = 'VMware LUN'
    $TypeName = 'UnityLun'
    $StatusCode = 204
  }

  Process {

    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If ($Sess.TestConnection()) {

        Foreach ($i in $ID) {

          Switch ($i.GetType().Name)
          {
            "String" {
              $Object = get-UnityVMwareLUN -Session $Sess -ID $i
              $ObjectID = $Object.id
              If ($Object.Name) {
                $ObjectName = $Object.Name
              } else {
                $ObjectName = $ObjectID
              }
            }
            "$TypeName" {
              Write-Verbose "Input object type is $($i.GetType().Name)"
              $ObjectID = $i.id
              If ($Object = Get-UnityVMwareLUN -Session $Sess -ID $ObjectID) {
                If ($Object.Name) {
                  $ObjectName = $Object.Name
                } else {
                  $ObjectName = $ObjectID
                }          
              }
            }
          }

          If ($ObjectID) {

            $UnitystorageResource = Get-UnitystorageResource -Session $sess | Where-Object {($_.Name -like $ObjectName) -and ($_.luns.id -like $ObjectID)}

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
            If (($PSBoundParameters.ContainsKey('size')) -or ($PSBoundParameters.ContainsKey('host'))) {
              $body["lunParameters"] = @{}
              $lunParameters = @{}
            
              If ($PSBoundParameters.ContainsKey('Size')) {
                $lunParameters["size"] = $($Size)
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

                  foreach ($h in $LUN.hostAccess) {

                    if (-not ($hostAccess.host.id -contains $h.host.id)) {
                      $hostAccess += $h
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

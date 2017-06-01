Function Set-UnityPool {

  <#
      .SYNOPSIS
      Modifies storage pool parameters.
      .DESCRIPTION
      Modifies storage pool parameters.
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
      ID of the pool or Pool Object.
      .PARAMETER NewName
      New name of the pool.
      .PARAMETER Description
      Description of the pool.
      .PARAMETER AddVirtualDisk
      Virtual Disks only with associated parameters to add to the pool. See examples for details.
      .PARAMETER AddraidGroup
      Parameters to add RAID groups to the pool (disk group, number of disks, RAID level, stripe length). See examples for details.
      .PARAMETER isFASTCacheEnabled
      Specify whether to enable FAST Cache on the storage pool.
      .PARAMETER isFASTVpScheduleEnabled
      Specify whether to enable scheduled data relocations for the pool.
      .PARAMETER alertThreshold
      For thin provisioning, specify the threshold, as a percentage, when the system will alert on the amount of subscription space used.
      .PARAMETER isHarvestEnabled
      Indicate whether the system should check the pool full high water mark for autodelete. 
      .PARAMETER poolSpaceHarvestHighThreshold
      Specify the pool full high watermark for the storage pool.
      .PARAMETER poolSpaceHarvestLowThreshold
      Specify the pool full low watermark for the storage pool.
      .PARAMETER isSnapHarvestEnabled
      Indicate whether the system should check the snapshot space used high water mark for auto-delete.
      .PARAMETER snapSpaceHarvestHighThreshold
      Specify the snapshot space used high watermark to trigger auto-delete on the storage pool.
      .PARAMETER snapSpaceHarvestLowThreshold
      Specify the snapshot space used low watermark to trigger auto-delete on the storage pool.
      .EXAMPLE
      Set-UnityPool -ID 'pool_10' -Description 'Modified description'

      Change the description of the pool with ID 'pool_10'
      .EXAMPLE
      Set-UnityPool -ID 'pool_10' -AddVirtualDisk @{'id'='vdisk_1';'tier'='Performance'}

      Add a virtual disk 'vdisk_1' to the pool with ID 'pool_10'
      .EXAMPLE
      Set-UnityPool -ID 'pool_10' -AddraidGroup @{"id"='dg_8';"numDisks"= 8; 'raidType'='RAID6'; 'stripeWidth'='8'}

      Add a raid group 'dg_8' to the pool with ID 'pool_10'
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High',DefaultParameterSetName="RaidGroup")]
  Param (
    #Default Parameters
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),

    #UnityPool
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Pool ID or Pool Object')]
    [Object[]]$ID,
    [Parameter(Mandatory = $false,HelpMessage = 'New Name of the Pool')]
    [String]$NewName,
    [Parameter(Mandatory = $false,HelpMessage = 'Pool Description')]
    [String]$Description,
    [Parameter(Mandatory = $false,ParameterSetName="VirtualDisk",HelpMessage = 'Parameters to add virtual disks to the pools')]
    [array]$AddVirtualDisk,
    [Parameter(Mandatory = $false,ParameterSetName="RaidGroup",HelpMessage = 'Parameters to add RAID groups to the pool (disk group, number of disks, RAID level, stripe length)')]
    [array]$AddraidGroup,
    [Parameter(Mandatory = $false,HelpMessage = 'Threshold at which the system will generate alerts about the free space in the pool')]
    [Int]$alertThreshold,
    [Parameter(Mandatory = $false,HelpMessage = 'Pool used space high threshold at which the system will automatically starts to delete snapshots in the pool, specified as a percentage with .01% granularity')]
    [Long]$poolSpaceHarvestHighThreshold,
    [Parameter(Mandatory = $false,HelpMessage = 'Pool used space low threshold under which the system will automatically stop deletion of snapshots in the pool, specified as a percentage with .01% granularity')]
    [Long]$poolSpaceHarvestLowThreshold,
    [Parameter(Mandatory = $false,HelpMessage = 'Snapshot used space high threshold at which the system automatically starts to delete snapshots in the pool, specified as a percentage with .01% granularity.')]
    [Long]$snapSpaceHarvestHighThreshold,
    [Parameter(Mandatory = $false,HelpMessage = 'Snapshot used space low threshold below which the system will stop automatically deleting snapshots in the pool, specified as a percentage with .01% granularity.')]
    [Long]$snapSpaceHarvestLowThreshold,
    [Parameter(Mandatory = $false,HelpMessage = 'Is Harvest Enabled ?')]
    [Bool]$isHarvestEnabled,
    [Parameter(Mandatory = $false,HelpMessage = 'Is Snapshot Harvest Enabled')]
    [Bool]$isSnapHarvestEnabled,
    [Parameter(Mandatory = $false,HelpMessage = 'Is FAST Cache Enabled ?')]
    [Bool]$isFASTCacheEnabled,
    [Parameter(Mandatory = $false,HelpMessage = 'Is FAST Vp Schedule Enabled ?  ')]
    [Bool]$isFASTVpScheduleEnabled
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    # Variables
    $URI = '/api/instances/pool/<id>/action/modify'
    $Type = 'Pool'
    $TypeName = 'UnityPool'
    $StatusCode = 204
    
    $tier = @{
      "Extreme_Performance" = "10"
      "Performance" = "20"
      "Capacity" = "30"
    }

    $Raid =@{
      "None" = "0"
      "RAID5" = "1"
      "RAID0" = "2"
      "RAID1" = "3"
      "RAID3" = "4"
      "RAID10" = "7"
      "RAID6" = "10"
      "Mixed" = "12"
      "Automatic" = "48879"
    }
  }

  Process {

    Foreach ($sess in $session) {

      Write-Debug -Message "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If ($Sess.TestConnection()) {

        Foreach ($i in $ID) {

          # Determine input and convert to object if necessary
          $Object,$ObjectID,$ObjectName = Get-UnityObject -Data $i -Typename $Typename -Session $Sess

          If ($ObjectID) {

            #### REQUEST BODY 

            # Creation of the body hash
            $body = @{}

            # Name parameter
            If ($NewName) {
              $body["name"] = "$($NewName)"
            }

            # Description parameter
            If ($Description) {
                  $body["description"] = "$($Description)"
            }

            If ($AddVirtualDisk) {

              # addPoolUnitParameters parameter
              $body["addPoolUnitParameters"] = @()

              Foreach ($vdisk in $AddVirtualDisk) {
                $addPoolUnitParameters = @{}
                $addPoolUnitParameters["poolUnit"] = @{}

                  $poolUnit = @{}
                  $poolUnit["id"] = "$($vdisk['id'])"

                  $tierType = "$($tier["$($vdisk['tier'])"])"

                $addPoolUnitParameters["poolUnit"] = $poolUnit
                $addPoolUnitParameters["tierType"] = $tierType

                $body["addPoolUnitParameters"] += $addPoolUnitParameters
              }
            }

            If ($AddraidGroup) {

              # addRaidGroupParameters parameter
              $body["addRaidGroupParameters"] = @()

                Foreach ($rg in $AddraidGroup) {
                  $addRaidGroupParameters = @{}
                  $addRaidGroupParameters["dskGroup"] = @{}

                    $diskGroup = @{}
                    $diskGroup["id"] = "$($rg['id'])"

                  $addRaidGroupParameters["dskGroup"] = $diskGroup

                  $addRaidGroupParameters["numDisks"] = "$($rg['numDisks'])"
                  $addRaidGroupParameters["raidType"] = "$($raid["$($rg['raidType'])"])"
                  $addRaidGroupParameters["stripeWidth"] = "$($rg['stripeWidth'])"
                  
                  $body["addRaidGroupParameters"] += $addRaidGroupParameters
                }
            }

            If ($alertThreshold) {
                  $body["alertThreshold"] = "$($alertThreshold)"
            }

            If ($poolSpaceHarvestHighThreshold) {
                  $body["poolSpaceHarvestHighThreshold"] = "$($poolSpaceHarvestHighThreshold)"
            }

            If ($poolSpaceHarvestLowThreshold) {
                  $body["poolSpaceHarvestLowThreshold"] = "$($poolSpaceHarvestLowThreshold)"
            }

            If ($snapSpaceHarvestHighThreshold) {
                  $body["snapSpaceHarvestHighThreshold"] = "$($snapSpaceHarvestHighThreshold)"
            }

            If ($snapSpaceHarvestLowThreshold) {
                  $body["snapSpaceHarvestLowThreshold"] = "$($snapSpaceHarvestLowThreshold)"
            }

            If ($PSBoundParameters.ContainsKey('isHarvestEnabled')) {
                  $body["isHarvestEnabled"] = $isHarvestEnabled
            }

            If ($PSBoundParameters.ContainsKey('isSnapHarvestEnabled')) {
                  $body["isSnapHarvestEnabled"] = $isSnapHarvestEnabled
            }

            If ($PSBoundParameters.ContainsKey('isFASTCacheEnabled')) {
                  $body["isFASTCacheEnabled"] = $isFASTCacheEnabled
            }

            If ($PSBoundParameters.ContainsKey('isFASTVpScheduleEnabled')) {
                  $body["isFASTVpScheduleEnabled"] = $isFASTVpScheduleEnabled
            }

            ####### END BODY - Do not edit beyond this line

            #Show $body in verbose message
            $Json = $body | ConvertTo-Json -Depth 10
            Write-Verbose $Json 

            #Building the URL
            $FinalURI = $URI -replace '<id>',$ObjectID

            $URL = 'https://'+$sess.Server+$FinalURI
            Write-Verbose "URL: $URL"

            #Sending the request
            If ($pscmdlet.ShouldProcess($Sess.Name,"Modify $Type $ObjectName")) {
              $request = Send-UnityRequest -uri $URL -Session $Sess -Method 'POST' -Body $Body
            }

            If ($request.StatusCode -eq $StatusCode) {

              Write-Verbose "$Type with ID $ObjectID has been modified"

              Get-UnityPool -Session $Sess -id $ObjectID

            }  # End If ($request.StatusCode -eq $StatusCode)
          } else {
            Write-Warning -Message "$Type with ID $i does not exist on the array $($sess.Name)"
          } # End If ($ObjectID)
        } # End Foreach ($i in $ID)
      } # End If ($Sess.TestConnection()) 
    } # End Foreach ($sess in $session)
  } # End Process
} # End Function

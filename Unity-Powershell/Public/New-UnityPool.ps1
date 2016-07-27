Function New-UnityPool {

  <#
      .SYNOPSIS
      Creates a new storage pool.
      .DESCRIPTION
      Creates a new storage pool. Storage pools are the groups of disks on which you create storage resources.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under Apache licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specify an UnitySession Object.
      .PARAMETER Name
      Name of the pool.
      .PARAMETER Description
      Description of the pool.
      .PARAMETER virtualDisk
      Virtual Disks only with associated parameters to add to the pool. See examples for details.
      .PARAMETER raidGroup
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
      New-UnityPool -Name 'POOL01' -virtualDisk @{"id"='vdisk_1';"tier"='Performance'},@{"id"='vdisk_2';"tier"='Performance'}

      Create pool named 'POOL01' with virtual disks 'vdisk_1' and 'vdisk_2'. Virtual disks are assigned to the performance tier. Apply to Unity VSA only.
      .EXAMPLE
      New-UnityPool -Name 'POOL01' -raidGroup @{"id"='dg_11';"numDisks"= 15; 'raidType'='RAID5'; 'stripeWidth'='5'}

      Create pool named 'POOL01' with with 15 disks from diskgroup ID 'dg_11'.RAID protection is a 'RAID5' with a stripe width of 5 (4+1). Apply to physical deployment only.
  #>

  [CmdletBinding(DefaultParameterSetName="RaidGroup")]
  Param (
    #Default Parameters
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    
    #UnityPool
    [Parameter(Mandatory = $true,Position = 1,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Pool Name')]
    [String[]]$Name,
    [Parameter(Mandatory = $false,HelpMessage = 'Pool Description')]
    [String]$Description,
    [Parameter(Mandatory = $false,ParameterSetName="VirtualDisk",HelpMessage = 'Parameters to add virtual disks to the pool')]
    [array]$virtualDisk,
    [Parameter(Mandatory = $false,ParameterSetName="RaidGroup",HelpMessage = 'Parameters to add RAID groups to the pool')]
    [array]$raidGroup,
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
    [Parameter(Mandatory = $false,HelpMessage = 'Is Harvest Enabled?')]
    [Bool]$isHarvestEnabled,
    [Parameter(Mandatory = $false,HelpMessage = 'Is Snapshot Harvest Enabled')]
    [Bool]$isSnapHarvestEnabled,
    [Parameter(Mandatory = $false,HelpMessage = 'Is FAST Cache Enabled?')]
    [Bool]$isFASTCacheEnabled,
    [Parameter(Mandatory = $false,HelpMessage = 'Is FAST Vp Schedule Enabled?')]
    [Bool]$isFASTVpScheduleEnabled
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"

    #Initialazing arrays
    $ResultCollection = @()

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

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      Foreach ($n in $Name) {

        # Creation of the body hash
        $body = @{}

        # Name parameter
        $body["name"] = "$($n)"

        # Description parameter
        If ($Description) {
              $body["description"] = "$($Description)"
        }

        If ($virtualDisk) {

          # addPoolUnitParameters parameter
          $body["addPoolUnitParameters"] = @()

          Foreach ($vdisk in $virtualDisk) {
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

        If ($raidGroup) {

          # addRaidGroupParameters parameter
          $body["addRaidGroupParameters"] = @()

            Foreach ($rg in $raidGroup) {
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

        If ($Sess.TestConnection()) {

          #Building the URI
          $URI = 'https://'+$sess.Server+'/api/types/pool/instances'
          Write-Verbose "URI: $URI"

          #Sending the request
          $request = Send-UnityRequest -uri $URI -Session $Sess -Method 'POST' -Body $Body

          Write-Verbose "Request status code: $($request.StatusCode)"

          If ($request.StatusCode -eq '201') {

            #Formating the result. Converting it from JSON to a Powershell object
            $results = ($request.content | ConvertFrom-Json).content

            Write-Verbose "LUN created with the ID: $($results.id) "

            #Executing Get-UnityUser with the ID of the new user
            Get-UnityPool -Session $Sess -ID $results.id
          }
        } else {
          Write-Information -MessageData "You are no longer connected to EMC Unity array: $($Sess.Server)"
        }
      }
    }
  }

  End {}
}

Function New-UnityPool {

  <#
      .SYNOPSIS
      Creates a pool.
      .DESCRIPTION
      Creates a pool.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under Apache licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .EXAMPLE
      New-UnityPool -Name 'POOL01' -virtualDisk -virtualDisk @{"id"='vdisk_1';"tier"='Performance'},@{"id"='vdisk_2';"tier"='Performance'}

      Create pool named 'POOL01' with virtual disks 'vdisk_1' and'vdisk_2'. Virtual disks are assigned to the performance tier. Apply to Unity VSA only.
  #>

  [CmdletBinding()]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $true,Position = 1,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Pool Name')]
    [String[]]$Name,
    [Parameter(Mandatory = $false,HelpMessage = 'Pool Description')]
    [String]$Description,
    [Parameter(Mandatory = $false,HelpMessage = 'Pool virtual disks')]
    $virtualDisk,
    [Parameter(Mandatory = $false,HelpMessage = 'Pool alert treshold')]
    [Int]$alertThreshold,
    [Parameter(Mandatory = $false,HelpMessage = 'Pool alert treshold')]
    [Long]$poolSpaceHarvestHighThreshold,
    [Parameter(Mandatory = $false,HelpMessage = 'Pool Space Harvest Low Threshold')]
    [Long]$poolSpaceHarvestLowThreshold,
    [Parameter(Mandatory = $false,HelpMessage = 'Snapshots Space Harvest High Threshold')]
    [Long]$snapSpaceHarvestHighThreshold,
    [Parameter(Mandatory = $false,HelpMessage = 'Snapshots Space Harvest Low Threshold')]
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
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"

    #Initialazing arrays
    $ResultCollection = @()

    $tier = @{
      "Extreme_Performance" = "10"
      "Performance" = "20"
      "Capacity" = "30"
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

        If (Test-UnityConnection -Session $Sess) {

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

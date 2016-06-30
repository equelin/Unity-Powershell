Function Set-UnityPool {

  <#
      .SYNOPSIS
      Modifies Pool parameters.
      .DESCRIPTION
      Modifies Pool parameters.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under Apache licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .EXAMPLE
      Set-UnityPool -Name 'Pool01' -Description 'Modified description'

      Change the description of the Pool named Pool01
      .EXAMPLE
      Set-UnityPool -Name 'Pool01' -AddVirtualDisk @{'id'='vdisk_1';'tier'='Performance'}

      Add a virtual disk to the pool named 'Pool01'
  #>

    [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Pool Name or Pool Object')]
    $Name,
    [Parameter(Mandatory = $false,HelpMessage = 'New Name of the Pool')]
    [String]$NewName,
    [Parameter(Mandatory = $false,HelpMessage = 'Pool Description')]
    [String]$Description,
    [Parameter(Mandatory = $false,HelpMessage = 'Pool virtual disks')]
    $AddVirtualDisk,
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

    $tier = @{
      "Extreme_Performance" = "10"
      "Performance" = "20"
      "Capacity" = "30"
    }
  }

  Process {

    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If (Test-UnityConnection -Session $Sess) {

        Foreach ($n in $Name) {

          # Determine input and convert to UnityPool object
          Switch ($n.GetType().Name)
          {
            "String" {
              $Pool = get-UnityPool -Session $Sess -Name $n
              $PoolID = $Pool.id
              $PoolName = $Pool.Name
            }
            "UnityPool" {
              Write-Verbose "Input object type is $($n.GetType().Name)"
              $PoolName = $n.Name
              If ($Pool = Get-UnityPool -Session $Sess -Name $PoolName) {
                        $PoolID = $n.id
              }
            }
          }

          If ($PoolID) {

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

            #Building the URI
            $URI = 'https://'+$sess.Server+'/api/instances/pool/'+$PoolID+'/action/modify'
            Write-Verbose "URI: $URI"

            #Sending the request
            If ($pscmdlet.ShouldProcess($PoolName,"Modify Pool")) {
              $request = Send-UnityRequest -uri $URI -Session $Sess -Method 'POST' -Body $Body
            }

            If ($request.StatusCode -eq '204') {

              Write-Verbose "Pool with ID: $PoolID has been modified"

              Get-UnityPool -Session $Sess -id $PoolID

            }
          } else {
            Write-Verbose "Pool $PoolName does not exist on the array $($sess.Name)"
          }
        }
      } else {
        Write-Information -MessageData "You are no longer connected to EMC Unity array: $($Sess.Server)"
      }
    }
  }

  End {}
}


#Get public and private function definition files
$Public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

#Dot source the files
Foreach($import in @($Public + $Private))
{
    Try
    {
        Write-Verbose "Import file: $($import.fullname)"
        . $import.fullname
    }
    Catch
    {
        Write-Error -Message "Failed to import file $($import.fullname): $_"
    }
}

# Export public functions
Export-ModuleMember -Function $Public.Basename

#Variable initialization

[UnitySession[]]$global:DefaultUnitySession = @()

#Custom Classes

Class UnitySession {
  [bool]$IsConnected
  [string]$Server
  [System.Collections.Hashtable]$Headers
  [System.Net.CookieCollection]$Cookies
  [string]$SessionId
  [string]$User
  [string]$Name
  [string]$model
  [string]$SerialNumber
}

Class UnitySystem {
  [string]$id
  $health
  [string]$name
  [string]$model
  [string]$serialNumber
  [string]$internalModel
  [string]$platform
  [string]$macAddress
}

Class UnityUser {
  [string]$id
  [string]$name
  $role
}

Enum LUNTypeEnum {
  GenericStorage = 1
  Standalone = 2
  VMwareISCSI = 3
}

Enum TieringPolicyEnum {
  Autotier_High = 0
  Autotier = 1
  Highest = 2
  Lowest = 3
  No_Data_Movement = 4
  Mixed = 0xffff

}

Class UnityLUN {
  [string]$id
  $health
  [string]$name
  [string]$description
  [LUNTypeEnum]$type
  [long]$sizeTotal
  [long]$sizeUsed
  [long]$sizeAllocated
  $perTierSizeUsed
  [bool]$isThinEnabled
  $storageResource
  $pool
  [string]$wwn
  [TieringPolicyEnum]$tieringPolicy
  $defaultNode
  [bool]$isReplicationDestination
  $currentNode
  $snapSchedule
  [bool]$isSnapSchedulePaused
  $ioLimitPolicy
  [long]$metadataSize
  [long]$metadataSizeAllocated
  [string]$snapWwn
  [long]$snapsSize
  [long]$snapsSizeAllocated
  $hostAccess
  [int]$snapCount
}

Enum StorageResourceTypeEnum {
  Database_Storage = 1
  Backup_Storage  = 2
  VM_Storage = 3
  Generic = 4
  Exchange_2007 = 5
  Exchange_2010 = 6
}

Enum RaidTypeEnum {
  None = 0
  RAID5 = 1
  RAID0 = 2
  RAID1 = 3
  RAID3 = 4
  RAID10 = 7
  RAID6 = 10
  Mixed = 12
  Automatic = 48879
}

Enum UsageHarvestStateEnum {
  Idle = 0
  Running = 1
  Could_Not_Reach_LWM = 2
  Paused_Could_Not_Reach_HWM = 3
  Failed = 4
}

Class UnityPool {
  [string]$id
  $health
  [string]$name
  [string]$description
  [StorageResourceTypeEnum]$storageResourceType
  [RaidTypeEnum]$raidType
  [long]$sizeFree
  [long]$sizeTotal
  [long]$sizeUsed
  [long]$sizeSubscribed
  [long]$alertThreshold
  [bool]$isFASTCacheEnabled
  $tiers
  [DateTime]$creationTime
  [bool]$isEmpty
  $poolFastVP
  [bool]$isHarvestEnabled
  [UsageHarvestStateEnum]$harvestState
  [bool]$isSnapHarvestEnabled
  [long]$poolSpaceHarvestHighThreshold
  [long]$poolSpaceHarvestLowThreshold
  [long]$snapSpaceHarvestHighThreshold
  [long]$snapSpaceHarvestLowThreshold
  [long]$metadataSizeSubscribed
  [long]$snapSizeSubscribed
  [long]$metadataSizeUsed
  [long]$snapSizeUsed
  [long]$rebalanceProgress
}


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

Class UnityBasicSystemInfo {
  [string]$id
  [string]$model
  [string]$name
  [string]$softwareVersion
  [string]$apiVersion
  [string]$earliestApiVersion
}

Class UnityFeature {
  [string]$id
  [string]$name
  [FeatureStateEnum]$state
  [FeatureReasonEnum]$reason
  $license
}

Class UnityLicense {
  [string]$id
  [string]$name
  [bool]$isInstalled
  [string]$version
  [bool]$isValid
  [DateTime]$issued
  [DateTime]$expires
  [bool]$isPermanent
  $feature
}

Class UnityStorageResource {
  [string]$id
  $health
  [string]$name
  [string]$description
  [StorageResourceTypeEnum]$type
  [bool]$isReplicationDestination
  [ReplicationTypeEnum]$replicationType
  [long]$sizeTotal
  [long]$sizeUsed
  [long]$sizeAllocated
  [ThinStatusEnum]$thinStatus
  [ESXFilesystemMajorVersionEnum]$esxFilesystemMajorVersion
  [ESXFilesystemBlockSizeEnum]$esxFilesystemBlockSize
  $snapSchedule
  [bool]$isSnapSchedulePaused
  $relocationPolicy
  $perTierSizeUsed
  $blockHostAccess
  [long]$metadataSize
  [long]$metadataSizeAllocated
  [long]$snapsSizeTotal
  [long]$snapsSizeAllocated
  [Int]$snapCount
  [string]$vmwareUUID
  $pools
  $datastores
  $filesystem
  $hostVVolDatastore
  $luns
  $virtualVolumes
}

Class UnityHealth {
  [HealthEnum]$value
  $descriptionIds
  $descriptions
  $resolutionIds
  $resolutions
}

Class UnityPoolUnit {
  [string]$id
  [PoolUnitTypeEnum]$type
  $health
  [string]$name
  [string]$description
  [string]$wwn
  [long]$sizeTotal
  [TierTypeEnum]$tierType
  $pool
}

Class UnityDnsServer {
  [string]$id
  [string]$domain
  [string[]]$addresses
  [DNSServerOriginEnum]$origin
}

#Custom Enum

Enum DNSServerOriginEnum {
  Unknown = 0
  Static = 1
  DHCP = 2
}

Enum PoolUnitTypeEnum {
   RAID_Group = 1
   Virtual_Disk = 2
}

Enum TierTypeEnum{
    None = 0
    Extreme_Performance = 10
    Performance = 20
    Capacity = 30
}

Enum HealthEnum{
  UNKNOWN = 0
  OK = 5
  OK_BUT = 7
  DEGRADED = 10
  MINOR = 15
  MAJOR = 20
  CRITICAL = 25
  NON_RECOVERABLE = 30
}

Enum LUNTypeEnum {
  GenericStorage = 1
  Standalone = 2
  VMwareISCSI = 3
}

Enum ESXFilesystemMajorVersionEnum {
   VMFS_3 = 3
   VMFS_5 = 5
}

Enum ESXFilesystemBlockSizeEnum {
    _1MB = 1
    _2MB = 2
    _4MB = 4
    _8MB = 8
}

Enum ReplicationTypeEnum {
  None = 0
  Local = 1
  Remote = 2
}

Enum TieringPolicyEnum {
  Autotier_High = 0
  Autotier = 1
  Highest = 2
  Lowest = 3
  No_Data_Movement = 4
  Mixed = 0xffff
}

Enum ThinStatusEnum {
  False = 0
  True = 1
  Mixed = 0xffff
}

Enum StorageResourceTypeEnum {
  filesystem = 1
  consistencyGroup  = 2
  vmwarefs = 3
  vmwareiscsi = 4
  lun = 8
  VVolDatastoreFS = 9
  VVolDatastoreISCSI = 10
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

Enum FeatureStateEnum {
  FeatureStateDisabled = 1
  FeatureStateEnabled = 2
  FeatureStateHidden = 3
}

Enum FeatureReasonEnum {
  FeatureReasonUnlicensed = 1
  FeatureReasonExpiredLicense = 2
  FeatureReasonPlatformRestriction = 3
  FeatureReasonExcluded = 4
}

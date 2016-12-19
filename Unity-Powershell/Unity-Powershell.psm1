
#Get Class, public and private function definition files
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

# Welcome screen
write-host ""
write-host "        Welcome to Unity-Powershell!"
write-host ""
write-host " Log in to an EMC Unity:  " -NoNewline
write-host "Connect-Unity" -foregroundcolor yellow
write-host " To find out what commands are available, type:  " -NoNewline
write-host "Get-Command -Module Unity-Powershell" -foregroundcolor yellow
write-host " To get help for a specific command, type:                   " -NoNewLine
write-host "get-help " -NoNewLine -foregroundcolor yellow
Write-Host "[verb]" -NoNewLine -foregroundcolor red
Write-Host "-Unity" -NoNewLine -foregroundcolor yellow
Write-Host "[noun]" -NoNewLine -foregroundcolor red
Write-Host " (Get-Help Get-UnityVMwareLUN)" -foregroundcolor yellow
write-host " To get extended help for a specific command, type:          " -NoNewLine
write-host "get-help " -NoNewLine -foregroundcolor yellow
Write-Host "[verb]" -NoNewLine -foregroundcolor red
Write-Host "-Unity" -NoNewLine -foregroundcolor yellow
Write-Host "[noun]" -NoNewLine -foregroundcolor red
Write-Host " -full" -NoNewLine -foregroundcolor yellow
Write-Host " (Get-Help Get-UnityVMwareLUN -Full)" -foregroundcolor yellow
write-host ""
write-host " If you need further help, please consult one of the following:" -ForegroundColor Green
write-host ""
Write-host "  * Online documentation at http://unity-powershell.readthedocs.io/en/latest/"
Write-host "  * Online Issues Tracker at https://github.com/equelin/Unity-Powershell/issues"
write-host ""
write-host " Licensed under the MIT License. (C) Copyright 2016 Erwan Quelin and the community."
write-host ""

#Custom Classes

Class UnitySession {
  [bool]$IsConnected
  [string]$Server
  [System.Collections.Hashtable]$Headers
  [System.Net.CookieCollection]$Cookies
  [Microsoft.PowerShell.Commands.WebRequestSession]$Websession
  [string]$SessionId
  [string]$User
  [string]$Name
  [string]$model
  [string]$SerialNumber

  ## Methods

  [bool] TestConnection () {

    $URI = 'https://'+$This.Server+'/api/types/system/instances'

    Try {
        Invoke-WebRequest -Uri $URI -ContentType "application/json" -Websession $this.Websession -Headers $this.Headers -Method 'GET'
    }
    Catch {
        $this.IsConnected = $false
        Write-Warning -Message "You are no longer connected to EMC Unity array: $($this.Server)"
        return $false
    }

    return $True
  }

  # Test if the Unity is a virtual appliance
  [bool] isUnityVSA () {
    If ($this.model -match 'UnityVSA') {
      return $True
    } else {
      return $False
    }
  }
}

Class UnitySystem {
  [string]$id
  [UnityHealth]$health
  [string]$name
  [string]$model
  [string]$serialNumber
  [string]$internalModel
  [string]$platform
  [string]$macAddress
  [bool]$isEULAAccepted
  [bool]$isUpgradeComplete
}

Class UnityUser {
  [string]$id
  [string]$name
  $role
}

Class UnityLUN {
  [string]$id
  [UnityHealth]$health
  [string]$name
  [string]$description
  [LUNTypeEnum]$type
  [UInt64]$sizeTotal
  [UInt64]$sizeUsed
  [UInt64]$sizeAllocated
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
  [UInt64]$metadataSize
  [UInt64]$metadataSizeAllocated
  [string]$snapWwn
  [UInt64]$snapsSize
  [UInt64]$snapsSizeAllocated
  $hostAccess
  [int]$snapCount

  ## Methods

  [void] ConvertToMB () {
    $this.sizeTotal = $this.sizeTotal / 1MB
    $this.sizeUsed = $this.sizeUsed / 1MB
    $this.sizeAllocated = $this.sizeAllocated / 1MB
    $this.metadataSize = $this.metadataSize / 1MB
    $this.metadataSizeAllocated = $this.metadataSizeAllocated / 1MB
    $this.snapsSizeAllocated = $this.snapsSizeAllocated / 1MB
  }

  [string] GetNaa () {
    $NAA = 'naa.' + ($($this.wwn) -replace ':','')
    return $NAA  
  }
}

Class UnityPool {
  [string]$id
  [UnityHealth]$health
  [string]$name
  [string]$description
  [StorageResourceTypeEnum]$storageResourceType
  [RaidTypeEnum]$raidType
  [UInt64]$sizeFree
  [UInt64]$sizeTotal
  [UInt64]$sizeUsed
  [UInt64]$sizeSubscribed
  [long]$alertThreshold
  [bool]$isFASTCacheEnabled
  [UnityPoolTier[]]$tiers
  [DateTime]$creationTime
  [bool]$isEmpty
  [UnityPoolFASTVP]$poolFastVP
  [bool]$isHarvestEnabled
  [UsageHarvestStateEnum]$harvestState
  [bool]$isSnapHarvestEnabled
  [float]$poolSpaceHarvestHighThreshold
  [float]$poolSpaceHarvestLowThreshold
  [float]$snapSpaceHarvestHighThreshold
  [float]$snapSpaceHarvestLowThreshold
  [UInt64]$metadataSizeSubscribed
  [UInt64]$snapSizeSubscribed
  [UInt64]$metadataSizeUsed
  [UInt64]$snapSizeUsed
  [Uint16]$rebalanceProgress

  ## Methods

  [void] ConvertToMB () {
    $this.sizeFree = $this.sizeFree / 1MB
    $this.sizeTotal = $this.sizeTotal / 1MB
    $this.sizeUsed = $this.sizeUsed / 1MB
    $this.sizeSubscribed = $this.sizeSubscribed / 1MB
    $this.metadataSizeSubscribed = $this.metadataSizeSubscribed / 1MB
    $this.snapSizeSubscribed = $this.snapSizeSubscribed / 1MB
    $this.metadataSizeUsed = $this.metadataSizeUsed / 1MB
    $this.snapSizeUsed = $this.snapSizeUsed / 1MB
  }
}

Class UnityPoolFASTVP {
  [FastVPStatusEnum]$status
  [FastVPRelocationRateEnum]$relocationRate
  [bool]$isScheduleEnabled
  [DateTime]$relocationDurationEstimate
  [UInt64]$sizeMovingDown
  [UInt64]$sizeMovingUp
  [UInt64]$sizeMovingWithin
  [Uint16]$percentComplete
  [PoolDataRelocationTypeEnum]$type
  [UInt64]$dataRelocated
  [DateTime]$lastStartTime
  [DateTime]$lastEndTime

  ## Methods

  [void] ConvertToMB () {
    $this.sizeMovingDown = $this.sizeMovingDown / 1MB
    $this.sizeMovingUp = $this.sizeMovingUp / 1MB
    $this.sizeMovingWithin = $this.sizeMovingWithin / 1MB
  }
}

Class UnityPoolTier {
  [TierTypeEnum]$tierType
  [RaidStripeWidthEnum]$stripeWidth
  [RaidTypeEnum]$raidType
  [UInt64]$sizeTotal
  [UInt64]$sizeUsed
  [UInt64]$sizeFree
  [UInt64]$sizeMovingDown
  [UInt64]$sizeMovingUp
  [UInt64]$sizeMovingWithin
  [String]$name
  $poolUnits
  [Int]$diskCount
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
  [UnityHealth]$health
  [string]$name
  [string]$description
  [StorageResourceTypeEnum]$type
  [bool]$isReplicationDestination
  [ReplicationTypeEnum]$replicationType
  [UInt64]$sizeTotal
  [UInt64]$sizeUsed
  [UInt64]$sizeAllocated
  [ThinStatusEnum]$thinStatus
  [ESXFilesystemMajorVersionEnum]$esxFilesystemMajorVersion
  [ESXFilesystemBlockSizeEnum]$esxFilesystemBlockSize
  $snapSchedule
  [bool]$isSnapSchedulePaused
  [TieringPolicyEnum]$relocationPolicy
  $perTierSizeUsed
  $blockHostAccess
  [UInt64]$metadataSize
  [UInt64]$metadataSizeAllocated
  [UInt64]$snapsSizeTotal
  [UInt64]$snapsSizeAllocated
  [Int]$snapCount
  [string]$vmwareUUID
  $pools
  $datastores
  $filesystem
  $hostVVolDatastore
  $luns
  $virtualVolumes

  ## Methods

  [void] ConvertToMB () {
    $this.sizeTotal = $this.sizeTotal / 1MB
    $this.sizeUsed = $this.sizeUsed / 1MB
    $this.sizeAllocated = $this.sizeAllocated / 1MB
    $this.metadataSize = $this.metadataSize / 1MB
    $this.metadataSizeAllocated = $this.metadataSizeAllocated / 1MB
    $this.snapsSizeTotal = $this.snapsSizeTotal / 1MB
    $this.snapsSizeAllocated = $this.snapsSizeAllocated / 1MB
  }
}

Class UnityPoolUnit {
  [string]$id
  [PoolUnitTypeEnum]$type
  [UnityHealth]$health
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

Class UnityNTPServer {
  [string]$id
  [string[]]$addresses
}

Class UnityNasServer {
  [string]$id
  [string]$name
  [UnityHealth]$health
  $homeSP
  $currentSP
  $pool
  [long]$sizeAllocated
  [bool]$isReplicationEnabled
  [bool]$isReplicationDestination
  [ReplicationTypeEnum]$replicationType
  [string]$defaultUnixUser
  [string]$defaultWindowsUser
  [NasServerUnixDirectoryServiceEnum]$currentUnixDirectoryService
  [bool]$isMultiProtocolEnabled
  [bool]$isWindowsToUnixUsernameMappingEnabled
  [bool]$allowUnmappedUser
  $cifsServer
  $preferredInterfaceSettings
  $fileDNSServer
  $fileInterface
  $virusChecker
}

Class UnityIpPort {
  [string]$id
  [string]$name
  [string]$shortName
  [string]$macAddress
  [bool]$isLinkUp
  $storageProcessor
}

Class UnityFileInterface {
  [string]$id
  $nasServer
  $ipPort
  [UnityHealth]$health
  [string]$ipAddress
  [IpProtocolVersionEnum]$ipProtocolVersion
  [string]$netmask
  [int]$v6PrefixLength
  [string]$gateway
  [int]$vlanId
  [string]$macAddress
  [string]$name
  [FileInterfaceRoleEnum]$role
  [bool]$isPreferred
  [ReplicationPolicyEnum]$replicationPolicy
  $sourceParameters
  [bool]$isDisabled
}

Class UnityFileDnsServer {
  [string]$id
  $nasServer
  [string[]]$addresses
  [string]$domain
  [ReplicationPolicyEnum]$replicationPolicy
  $sourceParameters
}

Class UnityCifsServer {
  [string]$id
  [string]$name
  [string]$description
  [string]$netbiosName
  [string]$domain
  [string]$lastUsedOrganizationalUnit
  [string]$workgroup
  [bool]$isStandalone
  [UnityHealth]$health
  $nasServer
  $fileInterfaces
  [bool]$smbcaSupported
  [bool]$smbMultiChannelSupported
  [string[]]$smbProtocolVersions
}

Class UnityFilesystem {
  [string]$id
  [UnityHealth]$health
  [string]$name
  [string]$description
  [FilesystemTypeEnum]$type
  [long]$sizeTotal
  [long]$sizeUsed
  [long]$sizeAllocated
  [bool]$isReadOnly
  [bool]$isThinEnabled
  $storageResource
  [bool]$isCIFSSyncWritesEnabled
  $pool
  [bool]$isCIFSOpLocksEnabled
  $nasServer
  [bool]$isCIFSNotifyOnWriteEnabled
  [bool]$isCIFSNotifyOnAccessEnabled
  [int]$cifsNotifyOnChangeDirDepth
  [TieringPolicyEnum]$tieringPolicy
  [FSSupportedProtocolEnum]$supportedProtocols
  [long]$metadataSize
  [long]$metadataSizeAllocated
  $perTierSizeUsed
  [long]$snapsSize
  [long]$snapsSizeAllocated
  [int]$snapCount
  [bool]$isSMBCA
  [AccessPolicyEnum]$accessPolicy
  [FSFormatEnum]$format
  [HostIOSizeEnum]$hostIOSize
  [ResourcePoolFullPolicyEnum]$poolFullPolicy
  $cifsShare
  $nfsShare
}

Class UnityCIFSShare {
  [string]$id
  [CIFSTypeEnum]$type
  $filesystem
  $snap
  [bool]$isReadOnly
  [string]$name
  [string]$path
  [string[]]$exportPaths
  [string]$description
  [DateTime]$creationTime
  [DateTime]$modifiedTime
  [bool]$isContinuousAvailabilityEnabled
  [bool]$isEncryptionEnabled
  [bool]$isACEEnabled
  [bool]$isABEEnabled
  [bool]$isBranchCacheEnabled
  [bool]$isDFSEnabled
  [CifsShareOfflineAvailabilityEnum]$offlineAvailability
  [string]$umask
}

Class UnityDiskGroup {
  [string]$id
  [string]$name
  [string]$emcPartNumber
  [TierTypeEnum]$tierType
  [DiskTechnologyEnum]$diskTechnology
  [bool]$isFASTCacheAllowable
  [long]$diskSize
  [long]$advertisedSize
  [int]$rpm
  [long]$speed
  [int]$totalDisks
  [int]$minHotSpareCandidates
  [HotSparePolicyStatusEnum]$hotSparePolicyStatus
  [int]$unconfiguredDisks
}

Class UnityFastCache {
  [string]$id
  [UnityHealth]$health
  [long]$sizeTotal
  [long]$sizeFree
  [int]$numberOfDisks
  [RaidTypeEnum]$raidLevel
  [UnityraidGroupCache[]]$raidGroups
}

Class UnityraidGroupCache {
  [string]$id
  [string]$name
  [UnityDiskGroup]$diskGroup
  [RaidTypeEnum]$raidLevel
  [RaidStripeWidthEnum]$raidModulus
  [int]$parityDisks
  $disks
}

Class UnityDisk {
  [string]$id
  [UnityHealth]$health
  [bool]$needsReplacement
  $parent
  [int]$slotNumber
  [int]$busId
  [string]$name
  [string]$manufacturer
  [string]$model
  [string]$version
  [string]$emcPartNumber
  [string]$emcSerialNumber
  [TierTypeEnum]$tierType
  $diskGroup
  [int]$rpm
  [bool]$isSED
  [long]$currentSpeed
  [long]$maxSpeed
  $pool
  [bool]$isInUse
  [bool]$isFastCacheInUse
  [long]$size
  [long]$rawSize
  [long]$vendorSize
  [string]$wwn
  [DiskTechnologyEnum]$diskTechnology
  $parentDae
  $parentDpe
  [string]$bank
  [int]$bankSlotNumber
  [string]$bankSlot
}

Class UnityHealth {
  [HealthEnum]$value
  [System.Array]$descriptionIds
  [System.Array]$descriptions
  [System.Array]$resolutionIds
  [System.Array]$resolutions
}

Class UnityHost {
  [string]$id
  [UnityHealth]$health
  [string]$name
  [string]$description
  [HostTypeEnum]$type
  [string]$osType
  [string]$hostUUID
  [string]$hostPushedUUID
  [string]$hostPolledUUID
  [DateTime]$lastPollTime
  [HostManageEnum]$autoManageType
  [HostRegistrationTypeEnum]$registrationType
  $hostContainer
  [array]$fcHostInitiators
  [array]$iscsiHostInitiators
  [array]$hostIPPorts
  [array]$storageResources
  [array]$hostLUNs
  [array]$datastores
  [array]$nfsShareAccesses
  [array]$hostVVolDatastore
  [array]$vms
}

Class UnityHostContainer {
  [string]$id
  [DateTime]$lastPollTime
  [int]$port
  [string]$name
  [HostContainerTypeEnum]$type
  $address
  [string]$description
  [string]$productName
  [string]$productVersion
  [UnityHealth]$health
  [array]$hosts
}

Class UnityMgmtInterface {
  [string]$id
  [InterfaceConfigModeEnum]$configMode
  $ethernetPort
  [IpProtocolVersionEnum]$protocolVersion
  [string]$ipAddress
  [string]$netmask
  [UInt64]$v6PrefixLength
  [string]$gateway
}

Class UnityMgmtInterfaceSettings {
  [string]$id
  [InterfaceConfigModeEnum]$v4ConfigMode
  [InterfaceConfigModeEnum]$v6ConfigMode
}

Class UnitySmtpServer {
  [string]$id
  [string[]]$address
  [SmtpTypeEnum]$type
}

Class UnityAlert {
  [string]$id
  [DateTime]$timestamp
  [SeverityEnum]$severity
  [string]$component
  [string]$messageId
  [string]$message
  [string]$descriptionId
  [string]$description
  [string]$resolutionId
  [string]$resolution
  [bool]$isAcknowledged
}

Class UnityIpInterface {
  [string]$id
  $ipPort
  [IpProtocolVersionEnum]$ipProtocolVersion
  [string]$ipAddress
  [string]$netmask
  [Uint64]$v6PrefixLength
  [string]$gateway
  [Uint64]$vlanId
  [IpInterfaceTypeEnum]$type
}

Class UnityEthernetPort {
  [string]$id
  [UnityHealth]$health
  $storageProcessor
  [bool]$needsReplacement
  [string]$name
  [UInt64]$portNumber
  [EPSpeedValuesEnum]$speed
  [UInt32]$mtu
  [ConnectorTypeEnum]$connectorType
  [bool]$bond
  [bool]$isLinkUp
  [string]$macAddress
  [bool]$isRSSCapable
  [bool]$isRDMACapable
  [EPSpeedValuesEnum]$requestedSpeed
  $parentIOModule
  $parentStorageProcessor
  [EPSpeedValuesEnum[]]$supportedSpeeds
  [UInt32]$requestedMtu
  [UInt64[]]$supportedMtus
  $parent
  [SFPSpeedValuesEnum[]]$sfpSupportedSpeeds
  [SFPSpeedValuesEnum[]]$sfpSupportedProtocols
}

Class UnityIscsiPortal {
  [string]$id
  $ethernetPort
  $iscsiNode
  [string]$ipAddress
  [string]$netmask
  [Uint64]$v6PrefixLength
  [string]$gateway
  [Uint64]$vlanId
  [IpProtocolVersionEnum]$ipProtocolVersion
}

Class UnityAlertConfig {
  [string]$id
  [LocaleEnum]$locale
  [bool]$isThresholdAlertsEnabled
  [SeverityEnum]$minEmailNotificationSeverity
  [string[]]$destinationEmails
  [SeverityEnum]$minSNMPTrapNotificationSeverity
}

Class UnityNfsServer {
  [string]$id
  [string]$hostName
  $nasServer
  $fileInterfaces
  [bool]$nfsv4Enabled
  [bool]$isSecureEnabled
  [KdcTypeEnum]$kdcType
  [string]$servicePrincipalName
  [bool]$isExtendedCredentialsEnabled
  [Datetime]$credentialsCacheTTL
}

#Custom Enum

Class UnityNFSShare {
  [string]$id
  [NFSTypeEnum]$type
  [NFSShareRoleEnum]$role
  $filesystem
  $snap
  [string]$name
  [string]$path
  [string[]]$exportPaths
  [string]$description
  [bool]$isReadOnly
  [DateTime]$creationTime
  [DateTime]$modificationTime
  [NFSShareDefaultAccessEnum]$defaultAccess
  [NFSShareSecurityEnum]$minSecurity
  $noAccessHosts
  $readOnlyHosts
  $readWriteHosts
  $rootAccessHosts
  $hostAccesses
}

Class UnityHostIPPort {
  [string]$id
  [string]$name
  [HostPortTypeEnum]$type
  [string]$address
  [string]$netmask
  [Uint64]$v6PrefixLength
  [bool]$isIgnored
  $host
}

Class UnitySnap {
  [string]$id
  [string]$name
  [string]$description
  $storageResource
  $lun
  $snapGroup
  $parentSnap
  [datetime]$creationTime
  [datetime]$expirationTime
  [SnapCreatorTypeEnum]$creatorType
  $creatorUser
  $creatorSchedule
  [bool]$isSystemSnap
  [bool]$isModifiable
  [string]$attachedWWN
  [FilesystemSnapAccessTypeEnum]$accessType
  [bool]$isReadOnly
  [datetime]$lastWritableTime
  [bool]$isModified
  [bool]$isAutoDelete
  [SnapStateEnum]$state
  [Uint64]$size
  $ioLimitPolicy
}

Class UnitySnapSchedule {
  [string]$id
  [string]$name
  [bool]$isDefault
  [bool]$isModified
  [ScheduleVersionEnum]$version
  [UnitySnapScheduleRule[]]$rules
  $storageResources  
}

Class UnitySnapScheduleRule {
  [string]$id
  [ScheduleTypeEnum]$type
  $minute
  $hours
  [DayOfWeekEnum[]]$daysOfWeek
  $daysOfMonth
  $interval
  [bool]$isAutoDelete
  $retentionTime
  [FilesystemSnapAccessTypeEnum]$accessType
}

#Custom Enum

Enum DayOfWeekEnum {
  Sunday = 1
  Monday = 2
  Tuesday = 3
  Wednesday = 4
  Thursday = 5
  Friday = 6
  Saturday = 7
}

Enum ScheduleTypeEnum {
  N_HOURS_AT_MM = 0
  DAY_AT_HHMM = 1
  N_DAYS_AT_HHMM = 2
  SELDAYS_AT_HHMM = 3
  NTH_DAYOFMONTH_AT_HHMM = 4
  UNSUPPORTED = 5
}

Enum ScheduleVersionEnum {
  Legacy = 1
  Simple = 2
}

Enum SnapCreatorTypeEnum {
  NONE = 0
  SCHEDULED = 1
  USER_CUSTOM = 2
  USER_DEFAULT = 3
  EXTERNAL_VSS = 4
  EXTERNAL_NDMP = 5
  EXTERNAL_RESTORE = 6
  EXTERNAL_REPLICATIONMANAGER = 8
  REPV2 = 9
  INBAND = 11
}

Enum FilesystemSnapAccessTypeEnum {
  Checkpoint = 1
  Protocol = 2
}

Enum SnapStateEnum {
  Ready = 2
  Faulted = 3
  Offline = 6
  Invalid = 7
  Initializing = 8
  Destroying = 9
}

Enum HostPortTypeEnum {
  IPv4 = 0
  IPv6 = 1
  NetworkName = 2
}

Enum NFSTypeEnum {
  Nfs_Share = 1
  Vmware_Nfs = 2
  Nfs_Snapshot = 3
}

Enum NFSShareRoleEnum {
  Production = 0
  Backup = 1
}

Enum NFSShareDefaultAccessEnum {
  NoAccess = 0
  ReadOnly = 1
  ReadWrite = 2
  Root = 3
}

Enum NFSShareSecurityEnum {
  Sys = 0
  Kerberos = 1
  KerberosWithIntegrity = 2
  KerberosWithEncryption = 3
}

Enum KdcTypeEnum {
  Custom = 0
  Unix = 1
  Windows = 2
}

Enum LocaleEnum {
  en_US = 0
  es_AR = 1
  de_DE = 2
  fr_FR = 3
  it_IT = 4
  ja_JP = 5
  ko_KR = 6
  pt_BR = 7
  ru_RU = 8
  zh_CN = 9
}

Enum HostLUNAccessEnum {
  NoAccess = 0
  Production = 1
  Snapshot = 2
  Both = 3
  Mixed = 0xffff
}

Enum SFPSpeedValuesEnum {
  Auto = 0
  _10Mbps = 10
  _100Mbps = 100
  _1Gbps = 1000
  _1500Mbps = 1500
  _2Gbps = 2000
  _3Gbps = 3000 
  _4Gbps = 4000
  _6Gbps = 6000
  _8Gbps = 8000 
  _10Gbps = 10000
  _12Gbps = 12000
  _16Gbps = 16000
  _32Gbps = 32000
  _40Gbps = 40000
  _100Gbps = 100000
  _1Tbps = 1000000
}

Enum ConnectorTypeEnum {
  Unknown = 0
  RJ45 = 1
  LC = 2
  MiniSAS_HD = 3
}

Enum EPSpeedValuesEnum {
  Auto = 0
  _10Mbps = 10
  _100Mbps = 100 
  _1Gbps = 1000
  _10Gbps = 10000
  _40Gbps = 40000
  _100Gbps = 100000
  _1Tbps = 1000000
}

Enum IpInterfaceTypeEnum {
  Mgmt = 1
  ISCSI = 2
  File = 3
  Replication = 4
}

Enum SeverityEnum {
  OK = 8
  DEBUG = 7
  INFO = 6
  NOTICE = 5
  WARNING = 4
  ERROR = 3
  CRITICAL = 2
  ALERT = 1
  EMERGENCY = 0
}

Enum SmtpTypeEnum {
  Default = 0
  PhoneHome = 1
}

Enum InterfaceConfigModeEnum {
  Disabled = 0
  Static = 1
  Auto = 2
}

Enum FastVPStatusEnum {
  Not_Applicable = 1
  Paused = 2
  Active = 3
  Not_started = 4 
  Completed = 5
  Stopped_by_user = 6
  Failed = 7
}

Enum FastVPRelocationRateEnum {
  High = 1
  Medium = 2
  Low = 3
  None = 4 
}

Enum PoolDataRelocationTypeEnum {
  Manual = 1
  Scheduled = 2
  Rebalance = 3
}

Enum HostContainerTypeEnum {
  UNKNOWN = 0
  ESX = 1
  VCENTER = 2
}

Enum HostRegistrationTypeEnum {
  UNKNOWN = 0
  MANUAL = 1
  ESXAUTO = 2
}

Enum HostManageEnum {
  UNKNOWN = 0
  VMWARE = 1
  OTHERS = 2
}

Enum HostTypeEnum {
  Unknown = 0
  HostManual = 1 
  Subnet = 2 
  NetGroup = 3 
  RPA = 4
  HostAuto = 5 
}

Enum HealthEnum {
  UNKNOWN = 0
  OK = 5
  OK_BUT = 7
  DEGRADED = 10
  MINOR = 15
  MAJOR = 20
  CRITICAL = 25
  NON_RECOVERABLE = 30
}

Enum RaidStripeWidthEnum {
  BestFit = 0
  _2 = 2
  _4 = 4
  _5 = 5
  _6 = 6
  _8 = 8
  _9 = 9
  _10 = 10
  _12 = 12
  _13 = 13
  _14 = 14
  _16 = 16
}

Enum HotSparePolicyStatusEnum {
  OK = 0
  Violated = 741
}

Enum DiskTechnologyEnum {
  SAS = 1
  NL_SAS = 2
  SAS_FLASH_2 = 6 
  SAS_FLASH_3 = 7
  Mixed = 50
  Virtual = 99
}

Enum RebootPrivilegeEnum {
  No_Reboot_Allowed = 0
  Reboot_Allowed = 1
   DU_Allowed = 2
}

Enum CifsShareOfflineAvailabilityEnum {
  Manual = 0
  Documents = 1
  Programs = 2
  None = 3
  Invalid = 255
}

Enum CIFSTypeEnum {
  Cifs_Share = 1
  Cifs_Snapshot = 2
}

Enum ResourcePoolFullPolicyEnum {
  Delete_All_Snaps = 0
  Fail_Writes = 1
}

Enum HostIOSizeEnum {
  General_8K = 0x2000
  General_16K = 0x4000
  General_32K = 0x8000
  General_64K = 0x10000
  Exchange2007 = 0x2001
  Exchange2010 = 0x8001
  Exchange2013 = 0x8002
  Oracle = 0x2002
  SQLServer = 0x2003
  VMwareHorizon = 0x2004
  SharePoint = 0x8003
  SAP = 0x2005
}

Enum FSFormatEnum {
  UFS32 = 0
  UFS64 = 2
}

Enum AccessPolicyEnum {
  Native = 0
  Unix = 1
  Windows = 2
}

Enum FilesystemTypeEnum {
  FileSystem = 1
  VMware = 2
}

Enum FSSupportedProtocolEnum {
  NFS = 0
  CIFS = 1
  Multiprotocol = 2
}

Enum IpProtocolVersionEnum {
  IPv4 = 4
  IPv6 = 6
}

Enum ReplicationPolicyEnum {
  Not_Replicated = 0
  Replicated = 1
  Overridden = 2
}

Enum FileInterfaceRoleEnum {
  Production = 0
  Backup = 1
}

Enum NasServerUnixDirectoryServiceEnum {
  None = 0
  NIS = 2
  LDAP = 3
}

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





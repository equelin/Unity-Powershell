# To enable debugging - Import-Module path\to\Module -ArgumentList $true

param (
    [bool]$DebugModule = $false
)

#Get Class, public and private function definition files
$Public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

#Dot source the files - idea from https://becomelotr.wordpress.com/2017/02/13/expensive-dot-sourcing/
Foreach($import in @($Public + $Private))
{
  If ($DebugModule) {
    Write-Verbose "Import file in debug mode: $($import.fullname)"
    . $import.fullname
  } Else {
    Try {
      Write-Verbose "Import file: $($import.fullname)"
      $ExecutionContext.InvokeCommand.InvokeScript($false, ([scriptblock]::Create([io.file]::ReadAllText($import))), $null, $null)
    }
    Catch {
      Write-Error -Message "Failed to import file $($import.fullname): $_"
    }
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
write-host " To get help for a specific command, type: " -NoNewLine
write-host "get-help " -NoNewLine -foregroundcolor yellow
Write-Host "[verb]" -NoNewLine -foregroundcolor red
Write-Host "-Unity" -NoNewLine -foregroundcolor yellow
Write-Host "[noun]" -NoNewLine -foregroundcolor red
Write-Host " (Get-Help Get-UnityVMwareLUN)" -foregroundcolor yellow
write-host " To get extended help for a specific command, type: " -NoNewLine
write-host "get-help " -NoNewLine -foregroundcolor yellow
Write-Host "[verb]" -NoNewLine -foregroundcolor red
Write-Host "-Unity" -NoNewLine -foregroundcolor yellow
Write-Host "[noun]" -NoNewLine -foregroundcolor red
Write-Host " -full" -NoNewLine -foregroundcolor yellow
Write-Host " (Get-Help Get-UnityVMwareLUN -Full)" -foregroundcolor yellow
Write-host " Documentation available at http://unity-powershell.readthedocs.io/en/latest/"
Write-host " Issues Tracker available at https://github.com/equelin/Unity-Powershell/issues"
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
  [version]$ApiVersion
  [Object[]]$Types

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
  [string]$systemUUID
  [string]$licenseActivationKey
  [string]$internalModel
  [string]$platform
  [string]$macAddress
  [bool]$isEULAAccepted
  [bool]$isUpgradeComplete
  [SPModelNameEnum[]]$supportedUpgradeModels
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
  [UInt64]$compressionSizeSaved
  [Uint16]$compressionPercent
  [Float]$compressionRatio
  [bool]$isCompressionEnabled

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
  [UInt64]$compressionSizeSaved
  [Uint16]$compressionPercent
  [Float]$compressionRatio
  [bool]$hasCompressionEnabledLuns

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
  [version]$softwareVersion
  [version]$apiVersion
  [version]$earliestApiVersion
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
  [CompressionStatusEnum]$compressionStatus
  [UInt64]$compressionSizeSaved
  [Uint16]$compressionPercent
  [Float]$compressionRatio

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

Class UnityMetric {
  [string]$id
  [string]$name
  [string]$path
  [Int]$type
  [string]$description
  [bool]$isHistoricalAvailable
  [bool]$isRealtimeAvailable
  [string]$unitDisplayString
}

Class UnityMetricRealTimeQuery {
  [string]$id
  [string[]]$paths
  [Uint32]$interval
  $maximumSamples
  [datetime]$expiration
}

Class UnityMetricQueryResult {
  $queryId
  [string]$path
  [datetime]$timestamp
  $values
}

Class UnityMetricValue {
  [string]$path
  [datetime]$timestamp
  [Uint32]$interval
  $values
}

class UnityHostInitiator {
  [string]$id
  [UnityHealth]$health
  [HostInitiatorTypeEnum]$type
  $parentHost
  [bool]$isIgnored
  [string]$nodeWWN
  [string]$portWWN
  [string]$chapUserName
  [bool]$isChapSecretEnabled
  [array]$paths
  [HostInitiatorIscsiTypeEnum]$iscsiType
  [bool]$isBound
  [HostInitiatorSourceTypeEnum]$sourceType
}

#Custom Enum

<#
  Name: ACEAccessLevelEnum
  Description: CIFS share access level granted or denied for a user or domain.  
#>
Enum ACEAccessLevelEnum {
  Read = 1 #Read access.  
  Write = 2 #Write access.  
  Full = 4 #Read and write access.  
}

<#
  Name: ACEAccessTypeEnum
  Description: Indicates whether the CIFS share access is granted or denied for a user. Use <b>None</b> to remove the Access Control Entries (ACEs) for a Security Identifier (SID) from the CIFS share.  
#>
Enum ACEAccessTypeEnum {
  Deny = 0 #Deny CIFS share access to a user.  
  Grant = 1 #Grant CIFS share acccess to a user.  
  None = 2 #Remove the ACE for a SID from a CIFS share.  
}

<#
  Name: AccessPolicyEnum
  Description: File system security access policies.  
#>
Enum AccessPolicyEnum {
  Native = 0 #Native Security.  
  Unix = 1 #UNIX Security.  
  Windows = 2 #Windows Security.  
}

<#
  Name: AllocationStatusEnum
  Description:  
#>
Enum AllocationStatusEnum {
  Not_Started = 0 # 
  Running = 1 # 
  Completed = 2 # 
  Failed = 3 # 
}

<#
  Name: AUSizeEnum
  Description: Allocation Unit possible sizes. The AUSize is granularity at which LUN's space is allocated in the pool.  
#>
Enum AUSizeEnum {
  AuSize_8K = 8192 #8K Allocation Unit.  
  AuSize_16K = 16384 #16K Allocation Unit.  
  AuSize_32K = 32768 #32K Allocation Unit.  
  AuSize_64K = 65536 #64K Allocation Unit.  
}

<#
  Name: AuthenticationTypeEnum
  Description: Type of authentication for the LDAP-based directory server.  
#>
Enum AuthenticationTypeEnum {
  Anonymous = 0 #Anonymous authentication means no authentication occurs and the NAS server uses an anonymous login to access the LDAP-based directory server.  
  Simple = 1 #Simple authentication means the NAS server must provide a bind distinguished name and password to access the LDAP-based directory server.  
  Kerberos = 2 #Kerberos authentication means the NAS server uses a KDC to confirm the identity when accessing the Active Directory.  
}

<#
  Name: BackendStorageTypeEnum
  Description:  
#>
Enum BackendStorageTypeEnum {
  Unknown = 0 # 
  VNX3 = 1 # 
  CloudArray = 2 # 
}

<#
  Name: BindContextEnum
  Description:  
#>
Enum BindContextEnum {
  Normal = 0 # 
  RebindStart = 1 # 
}

<#
  Name: BlockHostAccessEnum
  Description: Indicates the type of access a host has to a LUN or consistency group.  
#>
Enum BlockHostAccessEnum {
  Off = 0 #Access is disabled.  
  On = 1 #Access is enabled.  
  Mixed = 2 #(Applies to Consistency Groups only.) Indicates that LUNs in a consistency group have different host access.  
}

<#
  Name: CapabilityServiceLevelEnum
  Description: This is service level enumearation for capability profile's constraint.  
#>
Enum CapabilityServiceLevelEnum {
  Basic = 0 # 
  Bronze = 1 # 
  Silver = 2 # 
  Gold = 3 # 
  Platinum = 4 # 
}

<#
  Name: CapabilityTypeEnum
  Description:  
#>
Enum CapabilityTypeEnum {
  FastCache = 0 # 
  DiskTier = 1 # 
  RaidType = 2 # 
  SpaceEfficiency = 3 # 
  TieringPolicy = 4 # 
  UsageTag = 5 # 
  ServiceLevel = 6 # 
}

<#
  Name: CertificateTypeEnum
  Description: Types of certificates.  
#>
Enum CertificateTypeEnum {
  CA = 1 #Certificate Authority (CA) certificate.  
  Server = 2 #Server certificate.  
  Client = 3 #Client certificate.  
  TrustedPeer = 4 #Trusted Peer certificate.  
  Unknown = 99 #Unknown certificate type.  
}

<#
  Name: CHAPSecretTypeEnum
  Description: CHAP secret type.  
#>
Enum CHAPSecretTypeEnum {
  Binary = 0 #CHAP secret is binary.  
  ASCII = 1 #CHAP secret is ASCII.  
}

<#
  Name: CIFSTypeEnum
  Description: CIFS share type.  
#>
Enum CIFSTypeEnum {
  Cifs_Share = 1 #The share is created on a filesystem.  
  Cifs_Snapshot = 2 #The share is created on a snapshot.  
}

<#
  Name: CifsShareOfflineAvailabilityEnum
  Description: Defines a valid states of Offline Availability.  
#>
Enum CifsShareOfflineAvailabilityEnum {
  Manual = 0 #Only specified files will be available offline.  
  Documents = 1 #All files that users open will be available offline.  
  Programs = 2 #Program will preferably run from the offline cache even when connected to the network. All files that users open will be available offline.  
  None = 3 #Prevents clients from storing documents and programs in offline cache (default).  
  Invalid = 255 #Invalid state.  
}

<#
  Name: CombinedSystemStateEnum
  Description:  
#>
Enum CombinedSystemStateEnum {
  Update_Pending = 5 # 
  Denied_Verify = 10 # 
  Not_Supported = 20 # 
  Not_Verified = 30 # 
  Unknown = 100 # 
  Ok = 105 # 
  Ok_But = 107 # 
  Degraded = 110 # 
  Minor = 115 # 
  Major = 120 # 
  Critical = 125 # 
  Non_Recoverable = 130 # 
  Non_Reachable = 150 # 
}

<#
  Name: CompressionStatusEnum
  Description: Inline Compression status of the storage resource.  
#>
Enum CompressionStatusEnum {
  Disabled = 0 #Compression for the storage resource is disabled.  
  Enabled = 1 #Compression for the storage resource is enabled.  
  Mixed = 65535 #There is a mix of compression enabled and disabled LUNs. This only applies to Consistency Groups.  
}

<#
  Name: CompressionUnsupportedReasonEnum
  Description: Reason why Inline Compression (ILC) is not supported on the pool.  
#>
Enum CompressionUnsupportedReasonEnum {
  None = 0 #Inline compression (ILC) is supported.  
  Feature_Disabled = 1 #Inline compression (ILC) feature is disabled.  
  License_Uninstalled = 2 #Inline compression (ILC) license is not installed.  
  Pool_Type = 3 #Inline compression (ILC) is not supported because it is not Extreme Performance pool.  
}

<#
  Name: ConnectivityTypeEnum
  Description:  
#>
Enum ConnectivityTypeEnum {
  Unknown = 0 # 
  ISCSI_Software = 1 # 
  ISCSI_Offload = 2 # 
  FC = 3 # 
}

<#
  Name: ConnectorTypeEnum
  Description: Supported Connector types.  
#>
Enum ConnectorTypeEnum {
  Unknown = 0 #Connector Type is unknown.  
  RJ45 = 1 #Connector Type is RJ45.  
  LC = 2 #Connector Type is LC.  
  MiniSAS_HD = 3 #Connector Type is Mini SAS HD.  
  Copper_Pigtail = 4 # 
  No_Separable_Connector = 5 # 
  NAS_Copper = 6 # 
  Not_Present = 7 # 
}

<#
  Name: CRLReasonCodeEnum
  Description: Reason codes - per RFC5280 - for certificate revocation. NOTE: value 7 is not used  
#>
Enum CRLReasonCodeEnum {
  Unspecified = 0 #The revocation reason was not specified.  
  Key_Compromise = 1 #The associated private key has been compromised.  
  Ca_Compormise = 2 #The Certificate Authority (CA) that signed the certificate has been compromised.  
  Affiliation_Changed = 3 #The certificate affiliation has changed.  
  Superseded = 4 #The certificate has been superseded by another certificate.  
  Cessation_Of_Operation = 5 #The certificate is no longer used.  
  Certificate_Hold = 6 #The certificate is being held.  
  Remove_From_CRL = 8 #The certificate is being removed from the CRL.  
  Privilege_Withdrawn = 9 #The certificate privileges have been withdrawn.  
  Aa_Compromise = 10 #The Attribute Authority (AA) has been compromised.  
  Unknown = 99 #Unknown revocation reason.  
}

<#
  Name: DatastoreTypeEnum
  Description: Versions of VMFS datastore file system.  
#>
Enum DatastoreTypeEnum {
  Unknown = 0 #VMFS type unknown.  
  VMFS3 = 1 #VMFS version 3.  
  VMFS5 = 2 #VMFS version 5.  
}

<#
  Name: DayOfWeekEnum
  Description: Enumeration of days of the week.  
#>
Enum DayOfWeekEnum {
  Sunday = 1 #Sunday  
  Monday = 2 #Monday  
  Tuesday = 3 #Tuesday  
  Wednesday = 4 #Wednesday  
  Thursday = 5 #Thursday  
  Friday = 6 #Friday  
  Saturday = 7 #Saturday  
}

<#
  Name: DedupStateEnum
  Description:  
#>
Enum DedupStateEnum {
  Enabled = 0 # 
  Suspended = 1 # 
  Disabled = 2 # 
}

<#
  Name: DhsmConnectionModeEnum
  Description: A DhsmConnModeEnum represents the current operation mode of the file mover participating in this connection  
#>
Enum DhsmConnectionModeEnum {
  Enabled = 0 #Enabled allows both the creation of stub files and data migration through reads and writes.  
  Disabled = 1 #Disabled means neither stub files nor data migration is possible  
  RecallOnly = 2 #Recallonly means the policy engine is not allowed to create stub files, but the user is still able to trigger data migration by using a read or write request from the secondary file system to the Unity.  
}

<#
  Name: DiskTechnologyEnum
  Description: Possible disk technologies. <br/> <br/>  
#>
Enum DiskTechnologyEnum {
  SAS = 1 #The Serial attached SCSI (SAS) disk can be used for the Capacity storage tier. This disk type provides high performance and medium capacity storage for applications that requires a balance between performance and capacity.  
  NL_SAS = 2 #The Near-line serial attached SCSI (NL-SAS) disk can be used for the Performance storage tier. This disk type provides high capacity storage, but with lower overall performance than regular SAS and Flash disks.  
  SAS_FLASH_2 = 6 #The Medium Endurance Flash disk can be used for the Extreme Performance storage pool and for the FAST Cache.  
  SAS_FLASH_3 = 7 #The Low Endurance Flash disk can be used for the Extreme Performance storage pool tier but not for the FAST Cache.  
  Mixed = 50 #Applies only as an attribute value of an object containing mixed different types of disks. Disk cannot have this type.  
  Virtual = 99 # 
}

<#
  Name: DiskTierEnum
  Description: Drive Type tiers.  
#>
Enum DiskTierEnum {
  ExtremePerformanceTier = 0 #Tier that maps to Flash drives.  
  PerformanceTier = 1 #Tier that maps to SAS disks.  
  CapacityTier = 2 #Tier that maps to NL-SAS disks.  
  ExtremeMultiTier = 3 #Multi-tiered pool that includes Flash tier.  
  MultiTier = 4 #Multi-tiered pool that does not include Flash tier.  
}

<#
  Name: DiskTypeEnum
  Description: Possible disk types. <br/> <br/>  
#>
Enum DiskTypeEnum {
  Unknown = 0 #Unsupported disk type.  
  SAS = 5 #The Serial attached SCSI (SAS) disk can be used for Performance storage tier.  
  SAS_FLASH = 9 #The SAS Flash disk can be used for Extreme Performance storage pool tier and the FAST Cache.  
  NL_SAS = 10 #The Near-line serial attached SCSI (NL-SAS) disk type can be used for the Capacity storage tier.  
  SAS_FLASH_2 = 11 #The Medium Endurance Flash disk can be used for the Extreme Performance storage pool and for the FAST Cache.  
  SAS_FLASH_3 = 12 #The Low Endurance Flash disk can be used for the Extreme Performance storage pool tier but not for the FAST Cache.  
}

<#
  Name: DMOLockTypeEnum
  Description: DMO Lock Type Enumeration  
#>
Enum DMOLockTypeEnum {
  Read = 1 #Read Lock  
  Write = 2 #Write Lock  
}

<#
  Name: DMONotificationTypeEnum
  Description: DMO Notification Type Enumeration  
#>
Enum DMONotificationTypeEnum {
  Creation = 0 #Creation Notification  
  Modification = 1 #Modification Notification  
  Deletion = 2 #Deletion Notification  
}

<#
  Name: DNSServerOriginEnum
  Description: Source of the DNS server addresses.  
#>
Enum DNSServerOriginEnum {
  Unknown = 0 #Source of DNS server addresses is unknown.  
  Static = 1 #DNS server addresses are set manually.  
  DHCP = 2 #DNS server addresses are configured by DHCP.  
}

<#
  Name: EnclosureTypeEnum
  Description:  
#>
Enum EnclosureTypeEnum {
  Derringer_6G_SAS_DAE = 20 #25 Drive 6G DAE.  
  Pinecone_6G_SAS_DAE = 26 #12 Drive 6G DAE.  
  Steeljaw_6G_SAS_DPE = 27 #12 Drive 6G DPE.  
  Ramhorn_6G_SAS_DPE = 28 #25 Drive 6G DPE.  
  Tabasco_12G_SAS_DAE = 29 #25 Drive 12G DAE.  
  Ancho_12G_SAS_DAE = 30 #15 Drive 12G DAE.  
  Naga_12G_SAS_DAE = 32 #80 Drive 12G DAE.  
  Miranda_12G_SAS_DPE = 36 #25 Drive 12G DPE.  
  Rhea_12G_SAS_DPE = 37 #12 Drive 12G DPE.  
  Virtual_DPE = 100 #Virtual DPE.  
  Unsupported_Enclosure = 999 #Unsupported Enclosure.  
}

<#
  Name: EncryptionModeEnum
  Description: Data at Rest Encryption encryption mode  
#>
Enum EncryptionModeEnum {
  Unencrypted = 16 #No Data at Rest Encryption is activated.  
  Controller_Based_Encryption = 32 #Controller Based Encryption within the Data at Rest Encryption Feature on the targeted array is activated.  
}

<#
  Name: EncryptionStatusEnum
  Description: Data at Rest Encryption status on the storage system  
#>
Enum EncryptionStatusEnum {
  Invalid = 65535 #Invalid encryption status.  
  Fbe_Invalid = 0 #Invalid encryption status with internal errors.  
  Not_Encrypting = 1 #Not Encrypting.  
  Encrypting = 16 #Encrypting.  
  Encrypted = 32 #Encrypted.  
  Scrubbing = 64 #Scrubbing.  
  No_License = 254 #The Data at Rest Encryption license is not installed.  
  Unsupported = 255 #The Data at Rest Encryption is not supported.  
}

<#
  Name: EPSpeedValuesEnum
  Description: Supported Ethernet port transmission speeds.  
#>
Enum EPSpeedValuesEnum {
  Auto = 0 #Auto detected Ethernet port transmission speed.  
  _10Mbps = 10 #10 Mbps Ethernet port transmission speed.  
  _100Mbps = 100 #100 Mbps Ethernet port transmission speed.  
  _1Gbps = 1000 #1 Gbps Ethernet port transmission speed.  
  _10Gbps = 10000 #10 Gbps Ethernet port transmission speed.  
  _40Gbps = 40000 #40 Gbps Ethernet port transmission speed.  
  _100Gbps = 100000 #100 Gbps Ethernet port transmission speed.  
  _1Tbps = 1000000 #100 Tbps Ethernet port transmission speed.  
}

<#
  Name: ESXFilesystemBlockSizeEnum
  Description: VMFS block sizes.  
#>
Enum ESXFilesystemBlockSizeEnum {
  _1MB = 1 #1MB block.  
  _2MB = 2 #2MB block.  
  _4MB = 4 #4MB block.  
  _8MB = 8 #8MB block.  
}

<#
  Name: ESXFilesystemMajorVersionEnum
  Description: VMFS file system major versions.  
#>
Enum ESXFilesystemMajorVersionEnum {
  VMFS_3 = 3 #VMFS version 3.x.  
  VMFS_5 = 5 #VMFS version 5.x.  
}

<#
  Name: EsrsConfigStatusEnum
  Description: ESRS configuration status enum.  
#>
Enum EsrsConfigStatusEnum {
  Not_Attempted = 0 #ESRS configuration is not attempted  
  Success = 1 #ESRS configuration has successed  
  Failed = 2 #ESRS configuration failed  
}

<#
  Name: EsrsPolicyManagerStatusEnum
  Description: Policy Manager configuration and connection statuses.  
#>
Enum EsrsPolicyManagerStatusEnum {
  Disabled = 0 #Embedded ESRS Policy Manager is not enabled.  
  Connected = 1 #Embedded ESRS Policy Manager is enabled and connected.  
  Not_Connected = 2 #Embedded ESRS Policy Manager is enabled, but not running.  
  Unknown = 3 #Embedded ESRS Policy Manager status cannot be determined.  
}

<#
  Name: EsrsProxyStatusEnum
  Description:  
#>
Enum EsrsProxyStatusEnum {
  Disabled = 0 #Integrated Remote Support proxy server is not enabled.  
  Enabled = 1 #Embedded ESRS proxy server is enabled, but not connected.  
  Connected = 2 #Embedded ESRS proxy server is enabled and connected (on-line).  
  Not_Connected = 3 #Embedded ESRS proxy server is enabled, but not running (off-line).  
  Unknown = 4 #Embedded ESRS proxy server status cannot be determined.  
}

<#
  Name: EsrsStatusEnum
  Description: ESRS connection statuses.  
#>
Enum EsrsStatusEnum {
  Disabled = 0 #Remote Support is disabled.  
  Connected = 1 #Remote Support is functioning normally.  
  Not_Connected = 2 #Remote Support is enabled, but not connected.  
  Unknown = 3 #Remote Support status could not be determined.  
  Managed_Offline = 5 #Device is being managed by Remote Support server, but if offline.  
  Managed_Missing = 6 #Device is being managed by Remote Support server, but is not connected.  
  Managed_Removed = 7 #Device is removed from Remote Support server.  
  Unmanaged_Online = 11 #Device is in a transitioning state, it is not being managed by Remote Support server, it was previously online.  
  Unmanaged_Offline = 12 #Device is in a transitioning state, it is not being managed by Remote Support server, it was previously offline.  
  Unmanaged_Missing = 13 #Device is in a transitioning state, it is not being managed by Remote Support server, it was previously in a missing state.  
  Unmanaged_Removed = 14 #Device is in a transitioning state, it is not being managed by Remote Support server, it was previously in a removed state.  
  PendingAdd_Online = 15 #Device is in a transitioning state, it is pending managed, it was previously online.  
  PendingAdd_Offline = 16 #Device is in a transitioning state, it is pending managed, it was previously offline.  
  PendingAdd_Missing = 17 #Device is in a transitioning state, it is pending managed, it was previously in a missing state.  
  PendingAdd_Removed = 18 #Device is in a transitioning state, it is pending managed, it was previously in a removed state.  
  PendingDelete_Online = 19 #Device is in a transitioning state, it is pending for deletion, it was previously online.  
  PendingDelete_Offline = 20 #Device is in a transitioning state, it is pending for deletion, it was previously offline.  
  PendingDelete_Missing = 21 #Device is in a transitioning state, it is pending for deletion, it was previously in a missing state.  
  PendingDelete_Removed = 22 #Device is in a transitioning state, it is pending for deletion, it was previously in a removed state.  
  Managed_UnRegistered = 23 #Device is in a transitioning state, it will change to connected state once the pending request for managed state is processed.  
}

<#
  Name: EthernetPortStatusEnum
  Description: Possible Ethernet port statuses.  
#>
Enum EthernetPortStatusEnum {
  Unknown = 0 #Ethernet port status is unknown.  
  OK = 2 #Ethernet port status is OK.  
  Degraded = 3 #Ethernet port status is degraded.  
  Link_Up = 32784 #Ethernet port status is degraded.  
  Link_Down = 32785 #Ethernet port status is link down.  
  Speed_Negotiation_Failed = 32786 #Ethernet port status is speed negotiation failed.  
  Uninitialized = 33024 #Ethernet port status is uninitialized.  
  Empty = 33025 #Ethernet port status is empty.  
  Missing = 33026 #Ethernet port status is missing.  
  Faulted = 33027 #Ethernet port status is faulted.  
  Unavailable = 33028 #Ethernet port status is unavailable.  
  Disabled = 33029 #Ethernet port status is disabled.  
  SFP_Not_Present = 33280 #Ethernet port status is SFP not present.  
  Module_Not_Present = 33281 #Ethernet port status is module not present.  
  Port_Not_Present = 33282 #Ethernet port status is port not present.  
  Missing_SFP = 33283 #Ethernet port status is missing SFP.  
  Missing_Module = 33284 #Ethernet port status is missing module.  
  Incorrect_SFP_Type = 33285 #Ethernet port status is incorrect SFP type.  
  Incorrect_Module = 33286 #Ethernet port status is incorrect module.  
  SFP_Read_Error = 33287 #Ethernet port status is SFP read error.  
  Unsupported_SFP = 33288 #Ethernet port status is unsupported SFP.  
  Module_Read_Error = 33289 #Ethernet port status is module read error.  
  Exceeded_Maximum_Limits = 33290 #Ethernet port status is exceeded maximum limits.  
  Module_Powered_Off = 33291 #Ethernet port status is module powered off.  
  Unsupported_Module = 33292 #Ethernet port status is unsupported module.  
  Database_Read_Error = 33293 #Ethernet port status is database read error.  
  Faulted_SFP = 33294 #Ethernet port status is faulted SFP.  
  Hardware_Fault = 33295 #Ethernet port status is hardware Fault.  
  Disabled_User_Initiated = 33296 #Ethernet port status is Disabled user initiated.  
  Disabled_Encryption_Required = 33297 #Ethernet port status is disabled encryption required.  
  Disabled_Hardware_Fault = 33298 #Ethernet port status is disabled hardware fault.  
}

<#
  Name: EventCategoryEnum
  Description: Event category.  
#>
Enum EventCategoryEnum {
  User = 0 #User event.  
  Audit = 1 #Audit event.  
  Authentication = 2 #Authentication event.  
}

<#
  Name: FastCacheStateEnum
  Description: FAST Cache states.  
#>
Enum FastCacheStateEnum {
  Off = 0 #FAST Cache is off.  
  On = 1 #FAST Cache is on.  
}

<#
  Name: FastVPRelocationRateEnum
  Description: Possible FAST VP relocation rates.  
#>
Enum FastVPRelocationRateEnum {
  High = 1 #High relocation rate.  
  Medium = 2 #Medium relocation rate.  
  Low = 3 #Low relocation rate.  
  None = 4 #Relocation rate is not initialized by the storage system. Do not use this value in Modify requests: the storage system will respond with error.  
}

<#
  Name: FastVPStatusEnum
  Description: Possible FAST VP statuses.  
#>
Enum FastVPStatusEnum {
  Not_Applicable = 1 #Not applicable.  
  Paused = 2 #FAST VP is paused.  
  Active = 3 #FAST VP relocation or rebalancing is active.  
  Not_started = 4 #FAST VP relocation or rebalancing has not occurred yet.  
  Completed = 5 #Most recent FAST VP relocation or rebalancing completed successfully.  
  Stopped_by_user = 6 #Most recent FAST VP relocation or rebalancing stopped by user.  
  Failed = 7 #Most recent FAST VP relocation or rebalancing failed.  
}

<#
  Name: FastVPUnsupportedReasonEnum
  Description: Reason why FastVP is not supported on the pool.  
#>
Enum FastVPUnsupportedReasonEnum {
  None = 0 #FastVP is supported on the pool.  
  Feature_Disabled = 1 #FastVP feature is disabled.  
  License_Uninstalled = 2 #FastVP license is not installed.  
  Single_Tier = 3 #FastVP is not supported because the pool has a single tier only.  
}

<#
  Name: FeatureReasonEnum
  Description: Defines the reason if a license is not properly configured.  
#>
Enum FeatureReasonEnum {
  FeatureReasonUnlicensed = 1 # 
  FeatureReasonExpiredLicense = 2 # 
  FeatureReasonPlatformRestriction = 3 # 
  FeatureReasonExcluded = 4 # 
}

<#
  Name: FeatureStateEnum
  Description: Defines the applicable definition of the license.  
#>
Enum FeatureStateEnum {
  FeatureStateDisabled = 1 #The feature is not available on this storage system.  
  FeatureStateEnabled = 2 #The feature is available. Either it does not require a license or there is a valid license installed.  
  FeatureStateHidden = 3 #The feature is available, but currently not accessible to user because of the reason stated in the featureReason field  
}

<#
  Name: FileEventsPublisherFTLevelTypeEnum
  Description: Post-event notification policies for the File Event Service.  
#>
Enum FileEventsPublisherFTLevelTypeEnum {
  Ignore = 0 #Continue and tolerate lost events.  
  Accumulate = 1 #Continue and use a persistence file as a circular event buffer for lost events.  
  Guarantee = 2 #Continue and use a persistence file as a circular event buffer for lost events until the buffer is filled and then deny access to files systems where Events Publishing is Enabled.  
  Deny = 3 #Deny access to files systems where Events Publishing is enabled.  
}

<#
  Name: FileEventTypesEnum
  Description: The list of valid events for File Event Service.  
#>
Enum FileEventTypesEnum {
  OpenFileNoAccess = 0 #Sends a notification when a file is opened for a change other than read or write access. Protocols: CIFS, NFS(v4).  
  OpenFileRead = 1 #Sends a notification when a file is opened for read access. Protocols: CIFS, NFS(v4).  
  OpenFileWrite = 2 #Sends a notification when a file is opened for write access. Protocols: CIFS, NFS(v4).  
  CreateFile = 3 #Sends a notification when a file is created. Protocols: CIFS, NFS(v3/v4).  
  CreateDir = 4 #Sends a notification when a directory is created. Protocols: CIFS, NFS(v3/v4).  
  DeleteFile = 5 #Sends a notification when a file is deleted. Protocols: CIFS, NFS(v3/v4).  
  DeleteDir = 6 #Sends a notification when a directory is deleted. Protocols: CIFS, NFS(v3/v4).  
  CloseModified = 7 #Sends a notification when a file was modified before closing. Protocols: CIFS, NFS(v4).  
  CloseUnmodified = 8 #Sends a notification when a file was not modified before closing. Protocols: CIFS, NFS(v4).  
  RenameFile = 9 #Sends a notification when a file is renamed. Protocols: CIFS, NFS(v3/v4).  
  RenameDir = 10 #Sends a notification when a directory is renamed. Protocols: CIFS, NFS(v3/v4).  
  SetAclFile = 11 #Sends a notification when the security descriptor (ACL) on a files is modified. Protocols: CIFS.  
  SetAclDir = 12 #Sends a notification when the secuirty descriptor (ACL) on a directory is modified. Protocols: CIFS.  
  OpenDir = 13 #Sends a notification when a directory is opened. Protocols: CIFS, NFSv4.  
  CloseDir = 14 #Sends a notification when a directory is closed. Protocols: CIFS, NFSv4.  
  FileRead = 15 #Sends a notification when a file read is received over NFS. Protocols: NFS(v3/v4).  
  FileWrite = 16 #Sends a notification when a file write is received over NFS. Protocols: NFS(v3/v4).  
  SetSecFile = 17 #Sends a notification when a file security modification is received over NFS. Protocols: NFS(v3/v4).  
  SetSecDir = 18 #Sends a notification when a directory security modification is received over NFS. Protocols: NFS(v3/v4).  
  OpenFileReadOffline = 19 #Sends a notification when a offline file is opened for read access. Protocols: CIFS.  
  OpenFileWriteOffline = 20 #Sends a notification when a offline file in opened for write access. Protocols: CIFS.  
}

<#
  Name: FileInterfaceRoleEnum
  Description: Role of NAS server network interface.  
#>
Enum FileInterfaceRoleEnum {
  Production = 0 #Production network interfaces are used for all file protocols and services of NAS server. They are inactive while NAS server is in destination mode.  
  Backup = 1 #Backup network interfaces are used only for NDMP/NFS backup or Disaster Recovery testing. They are always active in all NAS server modes.  
}

<#
  Name: FilesystemSnapAccessTypeEnum
  Description: Indicates whether Checkpoint or Protocol access is granted to the file system snap.  
#>
Enum FilesystemSnapAccessTypeEnum {
  Checkpoint = 1 #Checkpoint access to enable access through a .ckpt folder in the file system.  
  Protocol = 2 #Protocol access to enable access through a file share.  
}

<#
  Name: FilesystemTypeEnum
  Description: The file system types.  
#>
Enum FilesystemTypeEnum {
  FileSystem = 1 #Underlying file system associated with a file system storage resource.  
  VMware = 2 #Underlying file system associated with a VMware NFS storage resource.  
}

<#
  Name: FSFormatEnum
  Description: UFS files system formats.  
#>
Enum FSFormatEnum {
  UFS32 = 0 #UFS32 file system.  
  UFS64 = 2 #UFS64 file system.  
}

<#
  Name: FSLockingPolicyEnum
  Description: File system locking policies. These policy choices control whether the NFSv4 range locks must be honored. Because NFSv3 is advisory by design, this policy allows specifying whether the NFSv4 locking feature behaves like NFSv3 (advisory mode) in order to be backward compatible with applications expecting an advisory locking scheme.  
#>
Enum FSLockingPolicyEnum {
  Advisory = 0 #No lock checking for NFS and honor SMB lock range only for SMB.  
  Mandatory = 1 #Honor SMB and NFS lock range.  
}

<#
  Name: FSRenamePolicyEnum
  Description: File system folder rename policies. These policy choices control whether directory can be renamed from NFS or SMB clients if at least one file is opened in the directory or in one of its child directories.  
#>
Enum FSRenamePolicyEnum {
  All_Rename_Allowed = 0 #All protocols are allowed to rename directories without any restrictions.  
  SMB_Rename_Forbidden = 1 #A directory rename from the SMB protocol will be denied if at least one file is opened in the directory or in one of its child directories.  
  All_Rename_Forbidden = 2 #Any directory rename request will be denied regardless of the protocol used, if at least one file is opened in the directory or in one of its child directories.  
}

<#
  Name: FSSupportedProtocolEnum
  Description: Network share protocols supported by file system.  
#>
Enum FSSupportedProtocolEnum {
  NFS = 0 #Only NFS share protocol supported by file system.  
  CIFS = 1 #Only SMB (also known as CIFS) share protocol is supported by file system.  
  Multiprotocol = 2 #Both share protocols NFS and SMB (also known as CIFS) are supported by file system.  
}

<#
  Name: HealthEnum
  Description: Possible values for health attribute.  
#>
Enum HealthEnum {
  UNKNOWN = 0 #Unknown.  
  OK = 5 #OK.  
  OK_BUT = 7 #OK But Minor Warning  
  DEGRADED = 10 #Degraded.  
  MINOR = 15 #Minor Issue.  
  MAJOR = 20 #Major Issue.  
  CRITICAL = 25 #Critical Issue.  
  NON_RECOVERABLE = 30 #Non Recoverable Issue.  
}

<#
  Name: HostContainerPotentialHostImportOptionEnum
  Description: This enumeration gives the recommendation for how to import candidate hosts based on the matching condition with the existing host.  
#>
Enum HostContainerPotentialHostImportOptionEnum {
  Import_New = 0 #Create a new host  
  Import_Existing = 1 #Matched an imported host by UUID. We will allow it to be imported  
  Import_Conflict = 2 #Matched multiple hosts on the array or matches UUID or initiators with other potential hosts. We will not allow the import  
  Import_Match = 3 #Match one host on the array. Will allow importing to replace that host  
  Import_Warn = 4 #Match ip address with another potential host. Will allow importing.  
}

<#
  Name: HostContainerPotentialHostMatchConditionEnum
  Description: This enumeration describes how the discovered candidate host matches the existing host/hosts that is/are already known to the storage array.  
#>
Enum HostContainerPotentialHostMatchConditionEnum {
  Match_Unknown = 0 #Unknown match condition  
  Match_UUID = 1 #UUID matches  
  Match_AllInitiators = 2 #all initiators match  
  Match_UUID_AllInitiators = 3 #UUID and all initiators match  
  Match_AllNetworkAddresses = 4 #all network addresses match  
  Match_UUID_AllNetworkAddresses = 5 #UUID and all network addresses match  
  Match_AllInitiators_AllNetworkAddresses = 6 #all initiators and all network addresses match  
  Match_UUID_AllInitiators_AllNetworkAddresses = 7 #UUID and all initiators and all network addresses match  
  Match_SomeInitiators = 8 #some initiators match  
  Match_UUID_SomeInitiators = 9 #UUID and some initiators match  
  Match_AllNetworkAddresses_SomeInitiators = 12 #all network addresses and some initiators match  
  Match_UUID_AllNetworkAddresses_SomeInitiators = 13 #UUID and all network addresses and some initiators match  
  Match_SomeNetworkAddresses = 16 #some network addresses match  
  Match_UUID_SomeNetworkAddresses = 17 #UUID and some network addresses match  
  Match_AllInitiators_SomeNetworkAddresses = 18 #some initiators and some network addresses match  
  Match_UUID_AllInitiators_SomeNetworkAddresses = 19 #UUID and some initiators and some network addresses match  
  Match_SomeInitiators_SomeNetworkAddresses = 24 #some initiators and some network addresses match  
  Match_UUID_SomeInitiators_SomeNetworkAddresses = 25 #UUID and some initiators and some network addresses match  
}

<#
  Name: HostContainerTypeEnum
  Description: A VMware host container type for managed VMs.  
#>
Enum HostContainerTypeEnum {
  UNKNOWN = 0 #Unknown type.  
  ESX = 1 #ESX type.  
  VCENTER = 2 #vCenter type.  
}

<#
  Name: HostInitiatorChapSecretTypeEnum
  Description: This enumeration describes the possible encoding types for the iSCSI chap secret.  
#>
Enum HostInitiatorChapSecretTypeEnum {
  CHAPSECRET_TYPE_BINARY = 0 #Encoded in binary mode.  
  CHAPSECRET_TYPE_ASCII = 1 #Encoded in ascii mode.  
}

<#
  Name: HostInitiatorIscsiTypeEnum
  Description: This enumeration describes the possible iSCSI types of an initiator.  
#>
Enum HostInitiatorIscsiTypeEnum {
  ISCSI_TYPE_UNKNOWN = 0 #Unknown iSCSI type or not an iSCSI initiator.  
  ISCSI_TYPE_HARDWARE = 1 #Hardware iSCSI type.  
  ISCSI_TYPE_SOFTWARE = 2 #Software iSCSI type.  
  ISCSI_TYPE_DEPENDENT = 3 #Hardware dependent adapter device. The iSCSI initiator needs to be bound to an IP address before it can be used.  
}

<#
  Name: HostInitiatorPathTypeEnum
  Description: Indicates how the host initiator path is registered.  
#>
Enum HostInitiatorPathTypeEnum {
  Manual = 0 #Registered manually.  
  ESX_Auto = 1 #Registered automatically by an ESXi host.  
  Other_Auto = 2 #Registered automatically by a non-ESXi host.  
}

<#
  Name: HostInitiatorSourceTypeEnum
  Description: This enumeration describes the possible source types of an initiator. This type regulates some aspects of system behavior.  
#>
Enum HostInitiatorSourceTypeEnum {
  Unknown = 0 #Unknown.  
  HP_Autotrespass = 2 #HP with Auto-trespass.  
  Open_Native = 3 #Open native (CLARiiON Open).  
  SGI = 9 #Silicon Graphics.  
  HP_No_Autotrespass = 10 #HP without Auto-trespass.  
  Dell = 19 #Dell.  
  Fujitsu_Siemens = 22 #Fujitsu-Siemens.  
  Clariion_Array_CMI = 25 #Remote CLARiiON array.  
  Tru64 = 28 #Tru64.  
  Recoverpoint = 31 #RecoverPoint.  
}

<#
  Name: HostInitiatorTypeEnum
  Description: This enumeration describes the possible protocol types of an initiator.  
#>
Enum HostInitiatorTypeEnum {
  UNKNOWN = 0 #Unknown initiator type.  
  FC = 1 #Fibre channel initiator.  
  ISCSI = 2 #iSCSI initiator.  
}

<#
  Name: HostIOSizeEnum
  Description: Typical size of writes from the server or other computer using the file system or LUN to the storage system. This setting is used to match the storage block size to the I/O of the primary application using the storage, which can optimize performance. Choose one of the suggested applications if you are using one of them, or check the setup guide or performance tuning information for the primary application, or stay with default 8K size for general use.  
#>
Enum HostIOSizeEnum {
  Exchange2007 = 8193 #Host I/O size is 8K for Exchange 2007 application  
  General_8K = 8192 #Host I/O size is 8K for general purpose  
  General_16K = 16384 #Host I/O size is 16K for general purpose  
  General_32K = 32768 #Host I/O size is 32K for general purpose  
  General_64K = 65536 #Host I/O size is 64K for general purpose  
  Exchange2010 = 32769 #Host I/O size is 32K for Exchange 2010 application  
  Exchange2013 = 32770 #Host I/O size is 32K for Exchange 2013 application  
  Oracle = 8194 #Host I/O size is 8K for Oracle DB application  
  SQLServer = 8195 #Host I/O size is 8K for Microsoft SQL Server application  
  VMwareHorizon = 8196 #Host I/O size is 8K for VMware Horizon VDI application  
  SharePoint = 32771 #Host I/O size is 32K for SharePoint application  
  SAP = 8197 #Host I/O size is 8K for SAP application  
}

<#
  Name: HostLUNAccessEnum
  Description: Indicates the type of access a host has to a LUN or consistency group.  
#>
Enum HostLUNAccessEnum {
  NoAccess = 0 #No access.  
  Production = 1 #Access to production LUNs only.  
  Snapshot = 2 #Access to LUN snapshots only.  
  Both = 3 #Access to both production LUNs and their snapshots.  
  Mixed = 65535 #(Applies to consistency groups only.) Indicates that LUNs in a consistency group have different host access. Do not use this value in Create or Modify requests.  
}

<#
  Name: HostLUNTypeEnum
  Description: Indicates the type of LUN to which a host has access.  
#>
Enum HostLUNTypeEnum {
  Unknown = 0 #Unknown LUN type.  
  LUN = 1 #Production LUN.  
  LUN_Snap = 2 #Snapshot LUN.  
}

<#
  Name: HostManageEnum
  Description: Indicates how the host is managed.  
#>
Enum HostManageEnum {
  UNKNOWN = 0 #Managed manually.  
  VMWARE = 1 #Automatically managed by an ESX server.  
  OTHERS = 2 #Managed by another method.  
}

<#
  Name: HostOperationalStatusEnum
  Description:  
#>
Enum HostOperationalStatusEnum {
  Unknown = 0 # 
  Other = 1 # 
  OK = 2 # 
  Degraded = 3 # 
  Stressed = 4 # 
  Predictive_Failure = 5 # 
  Error = 6 # 
  Non_Recoverable_Error = 7 # 
  Starting = 8 # 
  Stopping = 9 # 
  Stopped = 10 # 
  In_Service = 11 # 
  No_Contact = 12 # 
  Lost_Communication = 13 # 
  Aborted = 14 # 
  Dormant = 15 # 
  Supporting_Entity_in_Error = 16 # 
  Completed = 17 # 
  Power_Mode = 18 # 
  Temp_Unmounted = 19 # 
  Perm_Unmounted = 20 # 
  Initiators_Config_not_HA = 32768 # 
  No_LoggedIn_Initiator = 32769 # 
  Initiators_Data_Inconsistent = 32770 # 
  Network_Addresses_Data_Inconsistent = 32771 # 
  Tenant_Data_Inconsistent = 32772 # 
  Credential_Invalid = 34048 # 
  Storage_Not_Found = 34049 # 
  Certificate_Invalid = 34050 # 
}

<#
  Name: HostPortTypeEnum
  Description: This enumeration describes the possible IP address types of a host port.  
#>
Enum HostPortTypeEnum {
  IPv4 = 0 #IPv4.  
  IPv6 = 1 #IPv6.  
  NetworkName = 2 #Network name.  
}

<#
  Name: HostRegistrationTypeEnum
  Description: Indicates how initiators are registered to the host.  
#>
Enum HostRegistrationTypeEnum {
  UNKNOWN = 0 #Registration type is unknown.  
  MANUAL = 1 #Initiator is registered manually.  
  ESXAUTO = 2 #Initiator is registered automatically by an ESX server.  
}

<#
  Name: HostTypeEnum
  Description: Indicates the type of the host.  
#>
Enum HostTypeEnum {
  Unknown = 0 #Host configuration is unknown.  
  HostManual = 1 #A manually defined individual host system.  
  Subnet = 2 #All the hosts in a subnet.  
  NetGroup = 3 #A netgroup, used for NFS access. Netgroups are defined by NIS, and only available when NIS is active.  
  RPA = 4 #A RecoverPoint appliance host.  
  HostAuto = 5 #An auto-managed host - the system or an external agent identifies and updates the information for this host.  
  VNXSanCopy = 255 #Host defined for Block Migration from VNX Platform system.  
}

<#
  Name: HotSparePolicyStatusEnum
  Description:  
#>
Enum HotSparePolicyStatusEnum {
  OK = 0 # 
  Violated = 741 # 
}

<#
  Name: ImportCapabilityEnum
  Description:  
#>
Enum ImportCapabilityEnum {
  Importable = 0 # 
  Non_importable_internal_error = 1 # 
  Non_importable_only_support_vnx = 2 # 
  Non_importable_src_vdm_name_in_use_sess_completed = 3 # 
  Non_importable_src_vdm_name_in_use_sess_active = 4 # 
  Non_importable_src_vdm_name_in_use = 5 # 
  Non_importable_no_up_src_clnt_if = 6 # 
  Non_importable_no_fs_on_src_vdm = 7 # 
  Non_importable_reach_src_fs_limit = 8 # 
  Non_importable_nfsv4_not_support = 9 # 
  Non_importable_secnfs_not_support = 10 # 
  Non_importable_vdm_cannot_have_cifs_server = 11 # 
  Non_importable_srcmigif_more_error = 12 # 
  Non_importable_srcmigif_error = 13 # 
  Non_importable_invalid_vdm = 14 # 
  Non_importable_reach_src_if_limit = 15 # 
}

<#
  Name: ImportOpStatusEnum
  Description:  
#>
Enum ImportOpStatusEnum {
  Unknown = 0 # 
  Non_Recoverable_Error = 7 # 
  Configuring_Target_Resource = 32768 # 
  Enabling_Target_Resource_Access = 32769 # 
  Migrator_Cannot_Discover_Target_Resource = 32770 # 
  Ready_To_Migrate = 32771 # 
  Initial_Transfer_Inprogress = 32772 # 
  Delta_Transfer_Inprogress = 32773 # 
  Paused = 32774 # 
  Ready_To_Cutover = 32776 # 
  Lost_Communication = 32777 # 
  Target_Luns_Offline = 32779 # 
  Pending = 32780 # 
  Cutover_Sync_Complete = 32781 # 
  Session_Cleanup_Complete = 32782 # 
  Final_Transfer_Inprogress = 32783 # 
  Initialized = 33024 # 
  Starting = 33025 # 
  Start_Failed = 33026 # 
  Migrating_Data = 33027 # 
  Migrating_Data_Stopped = 33028 # 
  Migrating_Data_Failed = 33029 # 
  Migrating_Data_Failed_Stopped = 33030 # 
  Migrating_Configuration = 33031 # 
  Migrating_Configuration_Failed = 33032 # 
  Migrating_Configuration_Paused = 33033 # 
  Cutting_Over = 33280 # 
  Cutover_Failed = 33281 # 
  Syncing_Data = 33282 # 
  Syncing_Data_Stopped = 33283 # 
  Syncing_Data_Failed = 33284 # 
  Syncing_Data_Failed_Stopped = 33285 # 
  Ready_To_Complete = 33536 # 
  Completing = 33537 # 
  Complete_Failed = 33538 # 
  Completed = 33539 # 
  Cancelling = 33540 # 
  Cancel_Failed = 33541 # 
  Cancelled = 33542 # 
  Migrating_Data_Stopping = 33543 # 
  Syncing_Data_Stopping = 33544 # 
  Provisioning_Target_Paused = 33547 # 
  FS_OK = 34048 # 
  FS_Source_IO_Failure = 34049 # 
  FS_Destination_IO_Failure = 34050 # 
  FS_Connection_Failure = 34051 # 
  FS_Unrecoverable_Failure = 34052 # 
  VMO_Faulted = 34304 # 
  VMO_Offline = 34305 # 
  Element_Import_OK = 34560 # 
  Element_Import_Unable_To_Locate_Device = 34561 # 
  Element_Import_Bad_Block_On_Source_Device = 34562 # 
  Element_Import_Unable_To_Access_Device = 34563 # 
  Element_Import_LU_Trespassed = 34564 # 
  Element_Import_Source_Device_Inaccessible = 34565 # 
  Element_Import_Low_User_Link_Bandwidth = 34566 # 
  Element_Import_Concurrent_SanCopy_Session_Destinations = 34567 # 
  Element_Import_Error_Communicating_With_SanpView = 34568 # 
  Element_Import_Error_Communicating_With_SanpView_1 = 34569 # 
  Element_Import_Session_Inconsistent_State = 34570 # 
  Element_Import_Destination_Inconsistent_State = 34571 # 
  Element_Import_Auto_Recovery_Resume_Failed = 34572 # 
  Element_Import_All_Paths_failure = 34573 # 
  Element_Import_Access_Denied_To_Device = 34574 # 
  Element_Import_Not_Enough_Memory = 34575 # 
  Element_Import_Source_Device_Failure = 34576 # 
  Element_Import_Destination_Device_Failure = 34577 # 
  Element_Import_Destination_Device_Not_found = 34578 # 
  Element_Import_Target_LU_Not_Initialized = 34579 # 
  Element_Import_Command_TimedOut = 34580 # 
  Element_Import_Verifying_Frontend_TimedOut = 34581 # 
  Element_Import_Verifying_Frontend_TimedOut_Another_Operation = 34582 # 
  Element_Import_Source_Connectivity_TimedOut = 34583 # 
  Element_Import_Destination_Connectivity_TimedOut = 34584 # 
  Element_Import_RLP_IO_Failure = 34585 # 
  Element_Import_Total_Sessions_Limit_Reached = 34586 # 
  Element_Import_Incremental_Sessions_Limit_Reached = 34587 # 
  Element_Import_Incremental_Sessions_Total_Number_Reached = 34588 # 
  Element_Import_Limit_Of_Total_Sessions_Reached = 34589 # 
  Element_Import_Limit_Of_Total_Incremental_Sessions_Reached = 34590 # 
  Element_Import_Copy_Command_Queued = 34591 # 
  Element_Import_Session_Failed_On_Source_Or_Destination = 34592 # 
  Element_Import_Device_Cannot_Be_Located = 34593 # 
  Element_Import_No_Unused_Rlp_Luns = 34594 # 
  Element_Import_Reserved_Lun_Not_Support_Incremental_Sessions = 34595 # 
  Element_Import_Snapview_Reserved_Lun_Not_Enough_Space = 34596 # 
  Element_Import_Too_Many_Snapshots_On_Source_Lu = 34597 # 
  Element_Import_Cannot_Open_Reserved_Lun = 34598 # 
  Element_Import_Cannot_Get_Reserved_Lun_info = 34599 # 
  Element_Import_No_Space_On_Rlp = 34600 # 
  Element_Import_Rlp_Maximum_Devices = 34601 # 
  Element_Import_Session_With_No_Cache_Devices = 34602 # 
  Element_Import_Session_Failed_Write_To_Target_Device_Insufficient_Storage = 34603 # 
  Element_Import_Session_Device_Not_Ready = 34604 # 
  Element_Import_Session_Source_Device_Unavailable = 34605 # 
  Element_Import_Session_Source_In_Import_Session = 34606 # 
}

<#
  Name: ImportStageEnum
  Description: Import synchronization stage.  
#>
Enum ImportStageEnum {
  Initial = 0 #Initial sync.  
  Incremental = 1 #Incremental sync.  
  Final = 2 #Final sync.  
}

<#
  Name: ImportStateEnum
  Description: Import state.  
#>
Enum ImportStateEnum {
  Unknown = 0 # 
  Initialized = 50000 #Initialized.  
  Initial_Copy = 50001 #Initial Copy .  
  Ready_to_Cutover = 50002 #Ready to Cutover .  
  Paused = 50003 #Paused .  
  Cutting_Over = 50004 #Cutting Over .  
  Incremental_Copy = 50005 #Incremental Copy .  
  Ready_to_Commit = 50006 #Ready to Commit.  
  Committing = 50007 #Committing .  
  Completed = 50008 #Completed.  
  Cancelling = 50009 #Cancelling .  
  Cancelled = 50010 #Cancelled.  
  Pending = 50011 #Pending.  
  Syncing = 50012 #Syncing.  
  Error = 50013 #Error.  
}

<#
  Name: ImportTypeEnum
  Description: Type of import session.  
#>
Enum ImportTypeEnum {
  block = 0 # 
  nas = 1 # 
}

<#
  Name: ImportUnixDirectoryServiceEnum
  Description:  
#>
Enum ImportUnixDirectoryServiceEnum {
  Local = 0 # 
  NIS = 1 # 
  LDAP = 2 # 
  LocalThenNis = 3 # 
  LocalThenLdap = 4 # 
  None = 5 # 
  DirectMatch = 6 # 
}

<#
  Name: InterfaceConfigModeEnum
  Description: Configuration mode of management interfaces.  
#>
Enum InterfaceConfigModeEnum {
  Disabled = 0 #Management access is disabled.  
  Static = 1 #Management interface address is set manually.  
  Auto = 2 #Management interface address is configured by DHCP/SLAAC.  
}

<#
  Name: IOLimitPolicyStateEnum
  Description:  
#>
Enum IOLimitPolicyStateEnum {
  Global_Paused = 1 #Global Paused  
  Paused = 2 #Paused  
  Active = 3 #Active  
}

<#
  Name: IOLimitPolicyTypeEnum
  Description:  
#>
Enum IOLimitPolicyTypeEnum {
  Absolute = 1 #Absolute Value  
  Density_Based = 2 #Density-based Value  
}

<#
  Name: IPRecommendUsageEnum
  Description:  
#>
Enum IPRecommendUsageEnum {
  File = 1 # 
  ISCSI = 2 # 
}

<#
  Name: IpAddressOriginEnum
  Description:  
#>
Enum IpAddressOriginEnum {
  Disabled = 0 #Source of address is unknown.  
  Static = 1 # 
  DHCP = 2 # 
}

<#
  Name: IpInterfaceTypeEnum
  Description: Type of network interface.  
#>
Enum IpInterfaceTypeEnum {
  Mgmt = 1 #Network interfaces are used for management access.  
  ISCSI = 2 #Network interfaces are used for iSCSI access.  
  File = 3 #Network interfaces are used for File access.  
  Replication = 4 #Network interfaces are used for replication.  
}

<#
  Name: IpProtocolTypeEnum
  Description:  
#>
Enum IpProtocolTypeEnum {
  UDP = 0 # 
  TCP = 1 # 
  Vendor_Specific = 3 # 
  Other = 4 # 
}

<#
  Name: IpProtocolVersionEnum
  Description: IP version of network interface.  
#>
Enum IpProtocolVersionEnum {
  IPv4 = 4 #Network interface uses IPv4 address.  
  IPv6 = 6 #Network interface uses IPv6 address.  
}

<#
  Name: ISCSIConnectionStateEnum
  Description:  
#>
Enum ISCSIConnectionStateEnum {
  Unknown = 0 #iscsi connection state is unkown.  
  Logged_In = 1 #Connection is active and logged in.  
  Reconnecting = 2 #Currently trying to re-establish the connection.  
  Free = 3 #Target is discovered but not logged in.  
  No_Target = 4 #Target for the initiator has been removed.  
}

<#
  Name: JobStateEnum
  Description: Job state.  
#>
Enum JobStateEnum {
  Queued = 1 #Job is queued to run.  
  Running = 2 #Job is running.  
  Suspended = 3 #Job is suspended.  
  Completed = 4 #Job completed successfully.  
  Failed = 5 #Job is failed, interrupted or terminated.  
  Rolling_Back = 6 #Job has failed and is attempting to roll back.  
  Completed_With_Problems = 7 #Job ran to the end, but a task returned an error.  
}

<#
  Name: JobTaskStateEnum
  Description: Job task state. A job task is defined by the jobTask resource type.  
#>
Enum JobTaskStateEnum {
  Not_Started = 0 #Job task is waiting to run.  
  Running = 1 #Job task is running.  
  Completed = 2 #Job task completed successfully.  
  Failed = 3 #Job task failed.  
  Rolling_Back = 5 #Job task is rolling back.  
  Completed_With_Problems = 6 #Job ran to the end, but a task returned an error.  
  Suspended = 7 #Job is suspended.  
}

<#
  Name: KdcTypeEnum
  Description: Type of Kerberos Domain Controller used for secure NFS service.  
#>
Enum KdcTypeEnum {
  Custom = 0 #Use the custom Kerberos Domain Controller for secure NFS service. This requires a configured Kerberos server and an uploaded Kerberos key table file.  
  Unix = 1 #Use the Unix Kerberos Domain Controller (MIT/Heimdal) for secure NFS service. This requires a configured Kerberos server.  
  Windows = 2 #Use the Windows Kerberos Domain Controller for secure NFS service. This requires a configured SMB server joined to an Active Directory domain.  
}

<#
  Name: KeyManagerBackupKeysStatusEnum
  Description: Key store backup retrieval status  
#>
Enum KeyManagerBackupKeysStatusEnum {
  Invalid = 65535 #Invalid.  
  No_Retrieval_Required = 0 #No backup keys retrieval is required.  
  Retrieval_Required = 16 #Backup keys retrieval is required.  
  Retrieval_In_Progress = 32 #The backup keys retrieval is in progress.  
  Retrieval_Completed = 64 #The backup keys retrieval is completed.  
  Keystore_Inaccessible = 128 #The Keystore is inaccessible.  
}

<#
  Name: KmipStatusEnum
  Description: Key Management Interoperability Protocol (KMIP) compliant external key management feature status @author zhangp  
#>
Enum KmipStatusEnum {
  Invalid = 65535 #KMIP feature status is invalid. It cannot be determined  
  Disabled = 0 #KMIP feature is disabled.  
  Enabled = 1 #KMIP feature is enabled.  
  Unsupported = 255 #KMIP feature is not supported.  
}

<#
  Name: LDAPProtocolEnum
  Description: Indicates whether the LDAP protocol uses SSL for secure network communication. SSL encrypts data over the network and provides message and server authentication.  
#>
Enum LDAPProtocolEnum {
  ldap = 0 #LDAP protocol without SSL.  
  ldaps = 1 #(Default) LDAP protocol with SSL. When you enable LDAPS, make sure to specify the appropriate LDAPS port (usually port 636) and to upload an LDAPS trust certificate to the LDAP server.  
  unknown = 2 #Unknown protocol.  
}

<#
  Name: LicenseProductLineEnum
  Description: Indicates the EMC product family for which this license is valid.  
#>
Enum LicenseProductLineEnum {
  Unknown = 0 #Invalid product type  
  EUVSA = 1 #EMC UnityVSA product family  
  EU = 3 #EMC Unity product family  
}

<#
  Name: LicenseUnitOfMeasurementEnum
  Description: Unit of measurement for compliance with the given license instance  
#>
Enum LicenseUnitOfMeasurementEnum {
  Unknown = 0 #Indicates an invalid unit of measurement in license file.  
  CA = 1 #Indicates the unit of measurement will be registered capacity in TB.  
  CB = 2 #Indicates the unit of measurement will be raw capacity in TB.  
  CC = 3 #Indicates the unit of measurement will be usable capacity in TB.  
  IC = 4 #Indicates the unit of measurement will be instance measured per storage array.  
}

<#
  Name: LocaleEnum
  Description:  
#>
Enum LocaleEnum {
  pt_BR = 7 # 
  ru_RU = 8 # 
  ko_KR = 6 # 
  en_US = 0 # 
  es_AR = 1 # 
  de_DE = 2 # 
  fr_FR = 3 # 
  ja_JP = 5 # 
  zh_CN = 9 # 
}

<#
  Name: LUNTypeEnum
  Description: Types of LUNs.  
#>
Enum LUNTypeEnum {
  GenericStorage = 1 #Generic Storage Volume, i.e. LUN associated with Consistency group.  
  Standalone = 2 #Standalone Storage Volume (LUN), not associated with Consistency group.  
  VmWareISCSI = 3 #VMWare Storage Volume for VMFS datastore.  
}

<#
  Name: MetricTypeEnum
  Description:  
#>
Enum MetricTypeEnum {
  counter32 = 2 # 
  counter64 = 3 # 
  rate = 4 # 
  fact = 5 # 
  text = 6 # 
  virtualcounter32 = 7 # 
  virtualcounter64 = 8 # 
}

<#
  Name: MetricUnitEnum
  Description:  
#>
Enum MetricUnitEnum {
  OTHER = 0 # 
  BYTES = 1 # 
  BYTES_PER_SECOND = 2 # 
  PERCENTAGE = 3 # 
  COUNT = 4 # 
  MILLISECONDS = 5 # 
  IOS = 6 # 
  IOS_PER_SECOND = 7 # 
  PACKETS_PER_SECOND = 8 # 
  MICROSECONDS = 9 # 
  KILOBYTES = 10 # 
  KILOBYTES_PER_SECOND = 11 # 
  MEGABYTES = 12 # 
  COUNT_PER_SECOND = 13 # 
}

<#
  Name: MoveSessionPriorityEnum
  Description: An enumeration that represents the spectrum of priorities for a move session.  
#>
Enum MoveSessionPriorityEnum {
  Idle = 0 #With an idle priority the migration session there is no copy I/O generated. The migration session will continue to mirror host I/O.  
  Low = 1 #The low priority is designated for migration sessions that have the least precedence over other migration sessions.  
  Below_Normal = 2 #Migration sessions that have a below normal priority are slightly less critical than the average (or normal) migration session.  
  Normal = 3 #The default priority that is appropriate for most use cases.  
  Above_Normal = 4 #Migration sessions that have an above normal priority are slightly more critical than the average (or normal) migration session.  
  High = 5 #The high priority is reserved for migration sessions that take the highest precedence over other migration sessions.  
}

<#
  Name: MoveSessionStateEnum
  Description: An enumeration that represents the spectrum of priorities for a move session.  
#>
Enum MoveSessionStateEnum {
  Initializing = 0 #The migration session is in the process of initializing.  
  Queued = 1 #The migration session is queued to run. The system will begin the data transfer when there are sufficient resources.  
  Running = 2 #The running state indicates that the migration session is transferring data.  
  Failed = 3 #The migration session has failed. Consult the health of migration session for more details.  
  Cancelling = 4 #The cancelling state indicates that the migration session is in the process of being cancelled  
  Cancelled = 5 #The cancelled state indicates that the migration session has been cancelled.  
  Completed = 6 #The data transfer for the migration session has completed.  
}

<#
  Name: MoveSessionStatusEnum
  Description: An enumeration that represents the various status values for a move session.  
#>
Enum MoveSessionStatusEnum {
  OK = 0 #The migration(move) object is operating normally  
  PoolOffline = 1 #The pool went offline and the migration cannot continue. Please remove the migration session, address the issue, and recreate the migration session  
  PoolOutOfSpace = 2 #The pool exhausted the space available and the migration cannot continue. Please remove the migration session, address the issue, and recreate the migration session.  
  InternalError = 3 #The managed object encountered an internal error. Please contact your service provider.  
}

<#
  Name: NasServerFileTypeEnum
  Description: The available types for NAS server scope file uploads and downloads.  
#>
Enum NasServerFileTypeEnum {
  Unknown = 0 # 
  Ldap_Configuration = 1 #Upon configuration of your LDAP settings your NAS server attempts to connect to the LDAP server and automatically detects default LDAP schema depending on by the type of your LDAP server (such as SFU or OpenLDAP).  
  Ldap_CA_Certificate = 2 #A Certificaton Authority (CA) Certificate is used for validating certificate of the LDAP Server.  
  Username_Mappings = 3 #A NAS server text file (NTXMAP) to map Windows and UNIX user accounts with different names.  
  Virus_Checker_Configuration = 4 #Antivirus configuration file with parameters of CAVA service.  
  Users = 5 #Unix-style local users "passwd" file. Used for resolving unix users for NFS, FTP. Each line contains: username, encrypted password (optional), UID, GID.  
  Groups = 6 #Unix-style groups file. Each line contains: group name, GID (Group ID), and list of UIDs (group members user IDs).  
  Hosts = 7 #Unix-style hosts file. Each line contains: IP address, corresponding host name, and (optionally) an alias.  
  Netgroups = 8 #Unix-style file with network groups. Each line contains: group name and members such as hosts and other groups.  
  User_Mapping_Report = 9 #The report generated by an explicit request, for dry-run of users mapping update (typically before enabling multiprotocol on a NAS Server). This contains a reports about user mapping problems and upcoming NAS server changes.  
  Kerberos_Key_Table = 10 #Kerberos Key Table (keytab) file is required for secure NFS with custom Kerberos settings. It contains service principal names (SPNs), encryption methods and keys for secure NFS service.  
  Homedir = 11 #Configuration file with users name and home directory. Each line contains: a Windows domain (optional), a user name, a home directory (related to the NAS server root) and non-mandatory options.  
}

<#
  Name: NasServerTypeEnum
  Description:  
#>
Enum NasServerTypeEnum {
  Type32 = 32 # 
  Type64 = 64 # 
}

<#
  Name: NasServerUnixDirectoryServiceEnum
  Description: Define the Unix directory service used for looking up identity information for Unix such as UIDs, GIDs, net groups, and so on.  
#>
Enum NasServerUnixDirectoryServiceEnum {
  None = 0 #No Unix Directory Services is used.  
  NIS = 2 #Use NIS servers for looking up identity information.  
  LDAP = 3 #Use LDAP servers for looking up identity information.  
  LocalThenNIS = 4 # 
  LocalThenLDAP = 5 # 
}

<#
  Name: NFSShareDefaultAccessEnum
  Description: Default access level for all hosts that can access the share.  
#>
Enum NFSShareDefaultAccessEnum {
  NoAccess = 0 #Deny access to the share for the hosts.  
  ReadOnly = 1 #Allow read only access to the share for the hosts.  
  ReadWrite = 2 #Allow read write access to the share for the hosts.  
  Root = 3 #Allow read write access to the share for the hosts. Allow access to the share for root user.  
}

<#
  Name: NFSShareRoleEnum
  Description: Role of NAS server network interface.  
#>
Enum NFSShareRoleEnum {
  Production = 0 #Production NFS shares are used to access production file systems and snapshots. They are inactive while NAS server is in destination mode.  
  Backup = 1 #Backup NFS shares are used to access snapshots for NDMP/NFS backup or Disaster Recovery testing. They are always active in all NAS server modes.  
}

<#
  Name: NFSShareSecurityEnum
  Description: NFS enforced security type for users accessing an NFS share.  
#>
Enum NFSShareSecurityEnum {
  Sys = 0 #Allow user to authenticate with any NFS security types: UNIX, Kerberos, Kerberos with integrity and Kerberos with encryption.  
  Kerberos = 1 #Allow only Kerberos security for user authentication.  
  KerberosWithIntegrity = 2 #Allow only Kerberos with integrity and Kerberos with encryption security for user authentication.  
  KerberosWithEncryption = 3 #Allow only Kerberos with encryption security for user authentication.  
}

<#
  Name: NFSTypeEnum
  Description: NFS Share type.  
#>
Enum NFSTypeEnum {
  Nfs_Share = 1 #The NFS share is created on a filesystem.  
  Vmware_Nfs = 2 #The NFS share is created on a VMware datastore.  
  Nfs_Snapshot = 3 #The NFS share is created on a snapshot.  
}

<#
  Name: NodeEnum
  Description:  
#>
Enum NodeEnum {
  SPA = 0 # 
  SPB = 1 # 
  Unknown = 2989 #LUNs may return Unknown for current node when in an intermediate or failed state. Unknown is never valid in a configuration change request.  
}

<#
  Name: PingStatusEnum
  Description:  
#>
Enum PingStatusEnum {
  Alive = 0 # 
  Unreachable = 1 # 
}

<#
  Name: PlatformTypeEnum
  Description: The platform that current Unisphere Central is deployed on  
#>
Enum PlatformTypeEnum {
  vCenter = 0 # 
  ESXi = 1 # 
}

<#
  Name: PolicyComplianceStatusEnum
  Description: Overall compliance status of the Virtual Volume.  
#>
Enum PolicyComplianceStatusEnum {
  Compliant = 0 # 
  NonCompliant = 1 # 
  Unknown = 2 # 
}

<#
  Name: PoolConsumerTypeEnum
  Description: PoolConsumerTypeEnum describes different types of object consuming space from pool.  
#>
Enum PoolConsumerTypeEnum {
  FileSystem = 1 #storageResource of type filesystem.  
  ConsistencyGroup = 2 #storageResource of type consistencyGroup.  
  VMwareNFS = 3 #storageResource of type vmwareNfs.  
  VMwareVMFS = 4 #storageResource of type vmwareLun.  
  LUN = 8 #storageResource of type lun.  
  VVolDatastoreFS = 9 #storageResource of type VVol (file).  
  VVolDatastoreISCSI = 10 #storageResource of type VVol (block).  
  NASServer = 32768 #nasServer.  
}

<#
  Name: PoolDataRelocationTypeEnum
  Description: Pool FAST VP data relocation types.  
#>
Enum PoolDataRelocationTypeEnum {
  Manual = 1 #FAST VP relocation is supposed to start manualy.  
  Scheduled = 2 #FAST VP relocation is scheduled.  
  Rebalance = 3 #FAST VP is now rebalancing the pool.  
}

<#
  Name: PoolTypeEnum
  Description: Type of storage pool based on disk types.  
#>
Enum PoolTypeEnum {
  Unknown = 0 #The pool has an unknown tier.  
  Extreme_Performance = 10 #The pool has an extreme performance tier only.  
  Performance = 20 #The pool has a performance tier only.  
  Capacity = 30 #The pool has a capacity tier only.  
  Multi_Tier = 100 #The pool has multiple tiers.  
}

<#
  Name: PoolUnitOpStatusEnum
  Description: This must be merge of operational statuses of all classes derived from poolUnit. Some statuses are applicable for all poolUnit classes, the other are specific for certain subclasses. @author Stanislav Samolenkov  
#>
Enum PoolUnitOpStatusEnum {
  Unknown = 0 # 
  Other = 1 # 
  OK = 2 # 
  Degraded = 3 # 
  Stressed = 4 # 
  Predictive_Failure = 5 # 
  Error = 6 # 
  Non_Recoverable_Error = 7 # 
  Starting = 8 # 
  Stopping = 9 # 
  Stopped = 10 # 
  In_Service = 11 # 
  No_Contact = 12 # 
  Lost_Communication = 13 # 
  Aborted = 14 # 
  Dormant = 15 # 
  Supporting_Entity_in_Error = 16 # 
  Completed = 17 # 
  Power_Mode = 18 # 
  Online = 19 # 
  Available = 20 # 
  Offline = 21 # 
  Available_Connection_Invalid = 22 # 
  Available_Restore_Possible = 23 # 
  Inconsistency_Detected = 32768 # 
  No_Backend_Object = 32769 # 
  Under_Construction = 32770 # 
}

<#
  Name: PoolUnitTypeEnum
  Description:  
#>
Enum PoolUnitTypeEnum {
  RAID_Group = 1 # 
  Virtual_Disk = 2 # 
}

<#
  Name: PortRepCapabilityEnum
  Description: Port replication capability.  
#>
Enum PortRepCapabilityEnum {
  Sync_Replication = 0 #This port can be used for sync replication.  
  RecoverPoint = 1 #This port can be used for RecoverPoint.  
}

<#
  Name: ProxyProtocolEnum
  Description: Proxy server protocols.  
#>
Enum ProxyProtocolEnum {
  Http = 0 #Support proxy protocol is http.  
  Socks = 1 #Support proxy protocol is socks.  
}

<#
  Name: PublicKeyAlgoTypeEnum
  Description: Cryptographic algorithm used to generate the public key.  
#>
Enum PublicKeyAlgoTypeEnum {
  RSA = 1 #RSA algorithm.  
  DSA = 2 #Digital Signature Algorithm (DSA).  
  ECDSA = 3 #Elliptic Curve Digital Sigature Algorithm (ECDSA).  
  Unknown = 99 #Unknown algorithm.  
}

<#
  Name: QuotaPolicyEnum
  Description: A quota policy value represents a policy how disk usage (used by a user or within a quota tree) is calculated.  
#>
Enum QuotaPolicyEnum {
  Blocks = 1 #Calculates disk usage in terms of file system blocks (8 KB units) and the usage of all files including directories and symbolic links. With this policy, any operation resulting in allocation of blocks or removal of blocks such as creating, expanding, or deleting a directory; writing or deleting files; or creating or deleting symbolic links changes block usage. <br> Note: When using the blocks policy, the user can create a sparse file whose size is large (more than the limit), but that actually uses few blocks on the disk.  
  File_Size = 0 #Calculates disk usage only in terms of logical file sizes, ignoring directory sizes and symbolic links. Use this policy where file sizes are critical to quotas, such as where user usage is based on the size of the files created, and where sizes or their sum exceeding the limit is unacceptable. This policy is recommended in CIFS environments. With this policy , block usage depends solely on the number of bytes added to or removed from the file. Usage depends only on changes to a regular file. Directories and symbolic links are not considered.  
}

<#
  Name: QuotaStateEnum
  Description: A QuotaStateEnum value represents a state of the quota record (either user quota or tree quota) period.  
#>
Enum QuotaStateEnum {
  OK = 0 #No quota limits are exceeded.  
  Soft_Exceeded = 1 #Soft limit is exceeded, and grace period is not expired yet.  
  Soft_Exceeded_And_Expired = 2 #Soft limit is exceeded, and grace period is expired.  
  Hard_Exceeded = 3 #Hard limit is exceeded.  
}

<#
  Name: RaidGroupOpStatusEnum
  Description: Now raidGroup does not have operational statuses. Enum exists for compatibility with base class poolUnit. @author Stanislav Samolenkov  
#>
Enum RaidGroupOpStatusEnum {
  Unknown = 0 # 
  Other = 1 # 
  OK = 2 # 
  Degraded = 3 # 
  Stressed = 4 # 
  Predictive_Failure = 5 # 
  Error = 6 # 
  Non_Recoverable_Error = 7 # 
  Starting = 8 # 
  Stopping = 9 # 
  Stopped = 10 # 
  In_Service = 11 # 
  No_Contact = 12 # 
  Lost_Communication = 13 # 
  Aborted = 14 # 
  Dormant = 15 # 
  Supporting_Entity_in_Error = 16 # 
  Completed = 17 # 
  Power_Mode = 18 # 
}

<#
  Name: RaidStripeWidthEnum
  Description: This enum provides a set of choices for RAID group stripe widths, including parity or mirror disks. <br> For example, a stripe width of 5 for RAID5 specifies a 4+1 RAID5 configuration.  
#>
Enum RaidStripeWidthEnum {
  BestFit = 0 #BestFir value is used in automatic selection of stripe configuration.  
  _2 = 2 #A 2 disk group, usable in RAID10 1+1 configuration.  
  _4 = 4 #A 4 disk group, usable in RAID10 2+2 configuration.  
  _5 = 5 #A 5 disk group, usable in RAID5 4+1 configuration.  
  _6 = 6 #A 6 disk group, usable in RAID6 4+2 and RAID10 3+3 configurations.  
  _8 = 8 #A 8 disk group, usable in RAID6 6+2 and RAID10 4+4 configurations.  
  _9 = 9 #A 9 disk group, usable in RAID5 8+1 configuration.  
  _10 = 10 #A 10 disk group, usable in RAID6 8+2 and RAID10 5+5 configurations.  
  _12 = 12 #A 12 disk group, usable in RAID6 10+2 and RAID10 6+6 configurations.  
  _13 = 13 #A 13 disk group, usable in RAID5 12+1 configuration.  
  _14 = 14 #A 14 disk group, usable in RAID6 12+2 configuration.  
  _16 = 16 #raid strip width including parity disks, can be used in RAID6 14+2 configuration.  
}

<#
  Name: RaidTypeEnum
  Description: RAID group types or RAID levels.  
#>
Enum RaidTypeEnum {
  None = 0 #None.  
  RAID5 = 1 #RAID 5 has one parity disk. It provides best performance and space efficiency. RAID 5 groups provide protection for single disk faults and RAID5 is vulnerable to double disk fault. The preferred stripe width configurations are 4+1 and 8+1.  
  RAID0 = 2 #RAID 0 is a striping RAID. No parity or mirroring protection used. RAID 0 is not used in the storage system.  
  RAID1 = 3 #RAID 1 provides mirroring protection. RAID 1 is used only to create RAID groups for FAST Cache.  
  RAID3 = 4 #RAID 3 is not used in the storage system.  
  RAID10 = 7 #RAID 1/0 is mixture of striping and mirroring. It has a number of parity disks equal to half of the disks in the RAID group. The best for heavy transactional workloads with random writes. The preferred stripe width configuration is 4+4.  
  RAID6 = 10 #RAID 6 uses two disks for parity, it's mostly used with NL-SAS disks and read intensive workloads, for archives and backups. Two disks in the RAID group may fail simultaneously without data loss. The preferred stripe width configurations are 8+2 and 14+2.  
  Mixed = 12 #(Applies to pool objects only.) Indicates that RAID groups in a pool have different RAID levels. Do not use this value in Create or Modify requests.  
  Automatic = 48879 #Automatic is a valid value for create/modify requests. Indicates that the default RAID level will be used in pool's Create and Modify requests for the specified TierType. E.g. for SAS disk type (performance tier) RAID5, for NL-SAS disk type (capacity tier) RAID6. You can obtain the default RAID levels by querying the storageTier objects.  
}

<#
  Name: RebootPrivilegeEnum
  Description: Reboot for a time change is required only if the time shift exceeds a threshold of 1000 seconds. If a reboot is required, and allowed, on a single SP system or a system with only one SP operating, then clients will be unable to access data during the reboot.  
#>
Enum RebootPrivilegeEnum {
  No_Reboot_Allowed = 0 #Set time or NTP server if possible without a reboot.  
  Reboot_Allowed = 1 #Set time or NTP server if possible; reboot if needed, but do not allow data unavailability.  
  DU_Allowed = 2 #Set time or NTP server if possible; reboot if needed, even if this will cause data unavailability.  
}

<#
  Name: RecallPolicyEnum
  Description: Represents the recall policy  
#>
Enum RecallPolicyEnum {
  Full = 0 #Recalls the whole file to Unity on read request before the data is returned  
  PassThrough = 1 #Retrieves data without recalling the data to Unity  
  Partial = 2 #Recalls only the blocks required to satisfy the client read request.  
  None = 3 #Specifies no override  
}

<#
  Name: RecallPolicyOnDeleteEnum
  Description: Represents the policy about how to handle the remote data when deleting a DHSM connection.  
#>
Enum RecallPolicyOnDeleteEnum {
  Yes = 0 #Migrates the files back to the Unity before the connection is removed  
  No = 1 #Deletes the connection without checking for stub files that depend on the connection  
  Fail = 2 #Scans the file system for stub files that depend on the connection and fails on the first one.  
}

<#
  Name: RemoteSyslogFacilityTypeEnum
  Description: Remote syslog facility types.  
#>
Enum RemoteSyslogFacilityTypeEnum {
  Kernel_Messages = 0 #Kernel Messages  
  User_level_Messages = 1 #User-Level Messages  
  Syslogd = 5 #Messages Generated Internally by syslogd  
}

<#
  Name: RemoteSyslogLocaleEnum
  Description: Locales for remote syslog  
#>
Enum RemoteSyslogLocaleEnum {
  en_US = 0 #(Default) English.  
  es_AR = 1 #Spanish.  
  de_DE = 2 #German.  
  fr_FR = 3 #French.  
  ja_JP = 5 #Japanese.  
  ko_KR = 6 #Korean.  
  pt_BR = 7 #Brazilian Portuguese.  
  ru_RU = 8 #Russian.  
  zh_CN = 9 #Chinese.  
}

<#
  Name: RemoteSystemConnectionTypeEnum
  Description: Type of remote system connection.  
#>
Enum RemoteSystemConnectionTypeEnum {
  Sync = 0 #Synchronous replication.  
  Async = 1 #Asynchronous replication.  
  Both = 2 #Both Synchronous and Asynchronous replication.  
}

<#
  Name: RemoteSystemTypeEnum
  Description: Remote system platform type.  
#>
Enum RemoteSystemTypeEnum {
  VNXe = 0 #VNXe type remote system.  
  VNX = 1 #VNX type remote system.  
  Unknown = 99 #Unknown.  
}

<#
  Name: ReplicaTypeEnum
  Description: Defines the replica type of VVol. It can be base VVol, snapshot or fast-clone.  
#>
Enum ReplicaTypeEnum {
  Base = 0 #Base (primary) VVol.  
  PreSnapshot = 1 #Prepared snapshot VVol.  
  Snapshot = 2 #Snapshot VVol.  
  FastClone = 3 #Fast-clone VVol.  
}

<#
  Name: ReplicationCapabilityEnum
  Description: Remote system connection capability  
#>
Enum ReplicationCapabilityEnum {
  Sync = 0 #Synchronous replication connection  
  Async = 1 #Asynchronous replication connection  
  Both = 2 #Synchronous and Asynchronous replication connection  
  None = 3 #No regular replication connection  
}

<#
  Name: ReplicationEndpointResourceTypeEnum
  Description: Replication session end-point storage resource type.  
#>
Enum ReplicationEndpointResourceTypeEnum {
  filesystem = 1 #File system.  
  consistencyGroup = 2 #Consistency group.  
  vmwarefs = 3 #VMware (NFS).  
  vmwareiscsi = 4 #VMware (VMFS).  
  lun = 8 #LUN.  
  nasServer = 10 #NAS Server  
}

<#
  Name: ReplicationOpStatusEnum
  Description: Status of replication session end point.  
#>
Enum ReplicationOpStatusEnum {
  Unknown = 0 #Unknown.  
  Other = 1 #Other.  
  OK = 2 #OK.  
  Non_Recoverable_Error = 7 #Non-recoverable error.  
  Lost_Communication = 13 #Lost communication between source and destination end of the session.  
  Failed_Over_with_Sync = 33792 #Planned failover state - Production access from destination site.  
  Failed_Over = 33793 #DR Failed over - Production access from destination site.  
  Manual_Syncing = 33794 #Sync in-progress for a manual sync session.  
  Paused = 33795 #Session is in paused state.  
  Idle = 33796 #Session is idle.  
  Auto_Sync_Configured = 33797 #Sync in-progress for auto sync session.  
  Destination_Extend_Failed_Not_Syncing = 33803 #Destination resource extend failed, session is not syncing.  
  Destination_Extend_In_Progress = 33804 #Destination resource extend in-progress.  
  Active = 33805 #Replication session is active.  
  Lost_Sync_Communication = 33806 #Synchronous replication connection is down.  
  Destination_Pool_Out_Of_Space = 33807 #Destination resource related pool is out of space.  
}

<#
  Name: ReplicationPolicyEnum
  Description: Indicates the status of the NAS server object operating as a replication destination.  
#>
Enum ReplicationPolicyEnum {
  Not_Replicated = 0 #NAS object is not replicated over to the destination.  
  Replicated = 1 #NAS object is automatically synchronized over to the replication destination. Any modify or delete operations at the source will automatically be reflected on the destination.  
  Overridden = 2 #NAS object has been manually modified or overridden on the replication destination. Modifications on the source NAS server will have no effect on the overridden object on the replication destination.  
}

<#
  Name: ReplicationSessionNetworkStatusEnum
  Description: Replication session network status types.  
#>
Enum ReplicationSessionNetworkStatusEnum {
  Unknown = 0 #Unknown.  
  Other = 1 #Other.  
  OK = 2 #OK.  
  Lost_Communication = 5 #Lost communication to remote site.  
  Lost_Sync_Communication = 10 #Lost synchronous connection communication.  
}

<#
  Name: ReplicationSessionReplicationRoleEnum
  Description:  
#>
Enum ReplicationSessionReplicationRoleEnum {
  Source = 0 #Source side of a remote replication  
  Destination = 1 #Destination side of a remote replication  
  Loopback = 2 #Session is between resources from the same SP on the local array  
  Local = 3 #Session is between resources from different SPs on the local array  
  Unknown = 4 #Session role unknown  
}

<#
  Name: ReplicationSessionStatusEnum
  Description: Status of replication session end point.  
#>
Enum ReplicationSessionStatusEnum {
  Unknown = 0 #Unknown.  
  Other = 1 #Other.  
  OK = 2 #OK.  
  Paused = 3 #Paused.  
  Fatal_Replication_Issue = 4 #Fatal issue.  
  Lost_Communication = 5 #Lost communication to remote site.  
  Failed_Over = 6 #Failed over.  
  Failed_Over_With_Sync = 7 #Planned failed over.  
  Destination_Extend_Not_Syncing = 8 #Destination resource extension failed.  
  Destination_Extend_In_Progress = 9 #Destination pool full or destination resource is extending.  
  Lost_Sync_Communication = 10 #Lost synchronous replication connection.  
  Destination_Pool_Out_Of_Space = 11 #Destination pool out of space.  
}

<#
  Name: ReplicationSessionSyncStateEnum
  Description: Status of replication session scheduler.  
#>
Enum ReplicationSessionSyncStateEnum {
  Manual_Syncing = 0 #Sync in-proress for manual sync session.  
  Auto_Syncing = 1 #RPO sync in-progress for auto sync session.  
  Idle = 2 #Session is idle.  
  Unknown = 100 #Unknown.  
  Out_Of_Sync = 101 #Destination out of sync.  
  In_Sync = 102 #Both source and target are in sync.  
  Consistent = 103 #Destination is consistent with source data.  
  Syncing = 104 #Actively synchronizing.  
  Inconsistent = 105 #Destination is not consistent with source.  
}

<#
  Name: ReplicationTypeEnum
  Description: Replication type for replication session Valid values are: None, Local and Remote  
#>
Enum ReplicationTypeEnum {
  None = 0 #No replication session exists for the resource  
  Local = 1 #Replication session between resources from local system exists for the resource  
  Remote = 2 #Replication session between resources on local systemi and remote system exists for the resource  
}

<#
  Name: ResourcePoolFullPolicyEnum
  Description:  
#>
Enum ResourcePoolFullPolicyEnum {
  Delete_All_Snaps = 0 # 
  Fail_Writes = 1 # 
}

<#
  Name: RoleMappingTypeEnum
  Description: The type of role mapping. This may be localuser, ldapuser, or ldapgroup.  
#>
Enum RoleMappingTypeEnum {
  ldapgroup = 0 #LDAP Group role.  
  ldapuser = 1 #LDAP User role.  
  localuser = 2 #Local User role.  
  unknown = 3 #Unknown role type.  
}

<#
  Name: ScheduleTypeEnum
  Description: Enumeration of possible snapshot schedule types.  
#>
Enum ScheduleTypeEnum {
  N_HOURS_AT_MM = 0 #Snap every &lt;interval&gt; hours, at &lt;minutes&gt; past the hour. Supported parameters: interval (required), minutes (optional, default 0)  
  DAY_AT_HHMM = 1 #Specify a list of &lt;hour[,...]&gt; to snap one or more times each day at &lt;minutes&gt; past the hour. Supported parameters: hours (at least one required), minutes (optional).  
  N_DAYS_AT_HHMM = 2 #Snap every &lt;interval&gt; days at the time &lt;hours&gt;:&lt;minutes&gt;. Supported Parameters: interval (required), hours (optional, exactly one), minutes (optional).  
  SELDAYS_AT_HHMM = 3 #Snap on the selected &lt;daysOfWeek&gt;, at the time &lt;hours&gt;:&lt;minutes&gt;. Supported parameters: daysOfWeek (at least one required), hours (optional, default 0), minutes (optional, default 0)  
  NTH_DAYOFMONTH_AT_HHMM = 4 #Snap on the selected &lt;daysOfMonth&gt;, at the time &lt;hours&gt;:&lt;minutes&gt;. Supported parameters: daysOfMonth (at least one required), hours (optional, default 0), minutes (optional, default 0).  
  UNSUPPORTED = 5 # 
}

<#
  Name: ScheduleVersionEnum
  Description: Enumeration of snapshot schedule versions.  
#>
Enum ScheduleVersionEnum {
  Legacy = 1 #Legacy schedule with more than two rules of type HoursList, DaysInterval or MonthDaysList.  
  Simple = 2 #Simple schedule with two rules or less of rule type HoursInterval or WeekDaysList.  
}

<#
  Name: SchemeTypeEnum
  Description: LDAP server scheme type.  
#>
Enum SchemeTypeEnum {
  Unknown = 0 #Unknown LDAP scheme.  
  RFC2307 = 1 #OpenLDAP/iPlanet scheme.  
  Microsoft = 2 #Microsoft Identity Management for UNIX (IDMU/SFU) scheme.  
}

<#
  Name: SEDKeyStatusEnum
  Description: SED capable system flag  
#>
Enum SEDKeyStatusEnum {
  NO_KEY = 0 #Authentication key does not exist. The storage system generates the authentication key automatically at the first time you create a storage pool on a SED supporting system  
  VALID = 1 #Authentication key is valid.  
  CORRUPT = 2 #Authentication key is corrupt, which makes all data on SED drives unavailable on the next system reboot. To restore the authentication key, follow these steps: <ul> <li>Place both SPs in Service Mode.</li> <li>Run the svc_key_restore service script on one SP.</li> </ul> <p> For more information, see the <i>Service Commands Technical Notes</i>. To access these notes, go to the EMC Online Support website. From the storage system product page, search for the Service Commands.  
}

<#
  Name: SecurityStateEnum
  Description:  
#>
Enum SecurityStateEnum {
  Authenticated = 0 # 
  Accepted = 1 # 
  Waiting = 2 # 
  Denied = 3 # 
}

<#
  Name: ServiceContractStatusEnum
  Description: Service contract statuses.  
#>
Enum ServiceContractStatusEnum {
  Active = 0 #Service contract is active.  
  About_To_Expire = 1 #Service contract will expire in 90 days.  
  Expired = 2 #Service contract has expired.  
  Terminated = 3 #Contract is terminated.  
}

<#
  Name: ServiceLevelEnum
  Description: Service Level for the Capability Profile.  
#>
Enum ServiceLevelEnum {
  Basic = 0 #Basic service level.  
  Bronze = 1 #Bronze service level.  
  Silver = 2 #Silver service level.  
  Gold = 3 #Gold service level.  
  Platinum = 4 #Platinum service level.  
}

<#
  Name: ServiceTypeEnum
  Description: Types of services supported with certificate management.  
#>
Enum ServiceTypeEnum {
  VASA_HTTP = 2 #HTTP for VASA VVOL.  
  Mgmt_LDAP = 3 #LDAP for storage array administrative user authentication and authorization.  
  Mgmt_KMIP = 4 #KMIP for remote key storage and retrieval.  
  Unknown = 99 #Unknown service type.  
}

<#
  Name: SeverityEnum
  Description: Severity levels for alerts.  
#>
Enum SeverityEnum {
  OK = 8 #OK  
  DEBUG = 7 #Debug  
  INFO = 6 #Information  
  NOTICE = 5 #Notice  
  WARNING = 4 #Warning  
  ERROR = 3 #Error  
  CRITICAL = 2 #Critical  
  ALERT = 1 #Alert  
  EMERGENCY = 0 #Emergency  
}

<#
  Name: SFPProtocolValuesEnum
  Description: Supported SFP protocols.  
#>
Enum SFPProtocolValuesEnum {
  Unknown = 0 #SFP protocol is unknown.  
  FIBRE_CHANNEL = 1 #SFP protocol is Fibre Channel.  
  Ethernet = 2 #SFP protocol is Ethernet.  
  SAS = 3 #SFP protocol is SAS.  
}

<#
  Name: SFPSpeedValuesEnum
  Description: Supported SFP speeds.  
#>
Enum SFPSpeedValuesEnum {
  Auto = 0 #Auto detected SFP transmission speed.  
  _10Mbps = 10 #10 Mbps auto detected SFP transmission speed.  
  _100Mbps = 100 #100 Mbps SFP transmission speed.  
  _1Gbps = 1000 #1 Gbps SFP transmission speed.  
  _1500Mbps = 1500 #1500 Mbps SFP transmission speed.  
  _2Gbps = 2000 #2 Gbps SFP transmission speed.  
  _3Gbps = 3000 #3 Gbps SFP transmission speed.  
  _4Gbps = 4000 #4 Gbps SFP transmission speed.  
  _6Gbps = 6000 #6 Gbps SFP transmission speed.  
  _8Gbps = 8000 #8 Gbps SFP transmission speed.  
  _10Gbps = 10000 #10 Gbps SFP transmission speed.  
  _12Gbps = 12000 #12 Gbps SFP transmission speed.  
  _16Gbps = 16000 #16 Gbps SFP transmission speed.  
  _32Gbps = 32000 #32 Gbps SFP transmission speed.  
  _40Gbps = 40000 #40 Gbps SFP transmission speed.  
  _100Gbps = 100000 #100 Gbps SFP transmission speed.  
  _1Tbps = 1000000 #1 Tbps SFP transmission speed.  
}

<#
  Name: SignatureAlgoTypeEnum
  Description: Cryptographic algorithm used by the Certificate Authority (CA) to sign the certificate.  
#>
Enum SignatureAlgoTypeEnum {
  DSA_With_SHA = 1 #Digital Signature Algorithm (DSA) with Signature Hash Algrothm (SHA).  
  DSA_With_SHA1 = 2 #Digital Signature Algorithm (DSA) with SHA1.  
  MD5_With_RSA_Encryption = 3 #MD5 hash with RSA encryption.  
  RIPEMD160_With_RSA = 4 #RIPEMD algorithm 160-bit hash with RSA encryption.  
  SHA_With_RSA_Encryption = 5 #SHA hash with RSA encryption.  
  SHA1_With_RSA_Encryption = 6 #SHA1 hash with RSA encryption.  
  SHA224_With_RSA_Encryption = 7 #SHA2 224-bit hash with RSA encryption.  
  SHA256_With_RSA_Encryption = 8 #SHA2 256-bit hash with RSA encryption.  
  SHA384_With_RSA_Encryption = 9 #SHA2 384-bit hash with RSA encryption.  
  SHA512_With_RSA_Encryption = 10 #SHA2 512-bit hash with RSA encryption.  
  ECDSA_With_SHA1 = 11 #Elliptic Curve Digital Sigature Algorithm (ECDSA) hash with SHA1.  
  ECDSA_With_SHA224 = 12 #ECDSA hash with SHA2 224-bit.  
  ECDSA_With_SHA256 = 13 #ECDSA hash with SHA2 256-bit.  
  ECDSA_With_SHA384 = 14 #ECDSA hash with SHA2 384-bit.  
  ECDSA_With_SHA512 = 15 #ECDSA hash with SHA2 512-bit.  
  Unknown = 99 #Unknown algorithm.  
}

<#
  Name: SmtpTypeEnum
  Description:  
#>
Enum SmtpTypeEnum {
  Default = 0 # 
  PhoneHome = 1 # 
}

<#
  Name: SNMPAuthProtocolEnum
  Description:  
#>
Enum SNMPAuthProtocolEnum {
  MD5 = 1 #MD5 Authentication.  
  None = 0 #No Authentication.  
  SHA = 2 #SHA Authentication.  
}

<#
  Name: SNMPPrivacyProtocolEnum
  Description: SNMP privacy protocols  
#>
Enum SNMPPrivacyProtocolEnum {
  None = 0 #No privacy protocol.  
  AES = 1 #AES privacy protocol.  
  DES = 2 #DES privacy protocol.  
}

<#
  Name: SNMPVersionEnum
  Description: SNMP versions  
#>
Enum SNMPVersionEnum {
  v1 = 1 #Version 1.  
  v2c = 2 #Version 2.  
  v3 = 3 #Version 3.  
}

<#
  Name: SnapAccessLevelEnum
  Description: Indicates a type of access a host has to a snapshot.  
#>
Enum SnapAccessLevelEnum {
  ReadOnly = 0 #Allow read-only access to the snapshot for a host.  
  ReadWrite = 1 #Allow read/write access to the snapshot for a host.  
  ReadOnlyPartial = 2 #(Applies to consistency group snapshots only.) Indicates that host has read-only access to some individual snapshots in a consistency group snapshot. Do not use this value in Modify requests.  
  ReadWritePartial = 3 #(Applies to consistency group snapshots only.) Indicates that host has read/write access to some individual snapshots in a consistency group snapshot. Do not use this value in Modify requests.  
  Mixed = 4 #(Applies to consistency group snapshots only.) Indicates that host has read-only and read/write access to some individual snapshots in a consistency group snapshot. Do not use this value in Modify requests.  
}

<#
  Name: SnapCreatorTypeEnum
  Description: Enumeration of possible snapshot creator types.  
#>
Enum SnapCreatorTypeEnum {
  AppSync = 12 #Created by AppSync.  
  Snap_CLI = 11 #Created inband by SnapCLI.  
  None = 0 #Not specified.  
  Scheduled = 1 #Created by a snapshot schedule.  
  User_Custom = 2 #Created by a user with a custom name.  
  User_Default = 3 #Created by a user with a default name.  
  External_VSS = 4 #Created by Windows Volume Shadow Copy Service (VSS) to obtain an application consistent snapshot.  
  External_NDMP = 5 #Created by an NDMP backup operation.  
  External_Restore = 6 #Created as a backup snapshot before a snapshot restore.  
  External_Replication_Manager = 8 #Created by Replication Manager.  
  Replication = 9 #Created by a native replication operation.  
  File_Dedupe = 10 #Created by a File level Redundant Data Elimination (File De-dupe) operation.  
}

<#
  Name: SnapStateEnum
  Description: Enumeration of possible snapshot states.  
#>
Enum SnapStateEnum {
  Ready = 2 #The snaphot is operating normally.  
  Faulted = 3 #The storage pool that the snapshot belongs to is degraded.  
  Offline = 6 #The snapshot is not accessible possibly because the storage resource is not ready or the storage pool is full.  
  Invalid = 7 #The snapshot has become invalid becauuse of a non recoverable error.  
  Initializing = 8 #The snapshot is being created.  
  Destroying = 9 #The snapshot is being deleted.  
}

<#
  Name: SPModelNameEnum
  Description: All possible storageprocessor model names  
#>
Enum SPModelNameEnum {
  SP300 = 1 #Unity 300 or Unity 300F  
  SP400 = 2 #Unity 400 or Unity 400F  
  SP500 = 3 #Unity 500 or Unity 500F  
  SP600 = 4 #Unity 600 or Unity 600F  
}

<#
  Name: SpaceEfficiencyEnum
  Description: Space Efficiency enum  
#>
Enum SpaceEfficiencyEnum {
  Thick = 0 #Thick allocation.  
  Thin = 1 #Thin allocation.  
}

<#
  Name: SpeedValuesEnum
  Description: Supported SAS port transmission speeds.  
#>
Enum SpeedValuesEnum {
  _3Gbps = 3 #3 Gbps SAS port transmission speed.  
  _6Gbps = 6 #6 Gbps SAS port transmission speed.  
  _12Gbps = 12 #12 Gbps SAS port transmission speed.  
}

<#
  Name: SSLStrengthEnum
  Description: SSL strengths.  
#>
Enum SSLStrengthEnum {
  Unknown = 0 #Not set yet.  
  Low = 1 #Low SSL Strength - 40 bit.  
  Medium = 2 #Medium SSL Strength - 128 bit.  
  High = 3 #High SSL Strength - 168 bit.  
}

<#
  Name: SSLTypeEnum
  Description:  
#>
Enum SSLTypeEnum {
  None = 0 # 
  Optional = 1 # 
  Required = 2 # 
}

<#
  Name: StorageResourceTypeEnum
  Description:  
#>
Enum StorageResourceTypeEnum {
  filesystem = 1 # 
  consistencyGroup = 2 # 
  vmwarefs = 3 # 
  vmwareiscsi = 4 # 
  lun = 8 # 
  VVolDatastoreFS = 9 # 
  VVolDatastoreISCSI = 10 # 
}

<#
  Name: SupportCredentialStatusEnum
  Description: Status of the stored support credential.  
#>
Enum SupportCredentialStatusEnum {
  Not_Set = 0 #Support credentials are not set.  
  Unvalidated = 1 #Validation could not be performed because of various reasons. For example, there may be no internet connection.  
  Valid = 2 #Stored support credentials have been validated previously.  
  Invalid = 3 #Stored support credentials are incorrect and cannot pass validation.  
}

<#
  Name: SvcCRUTypeEnum
  Description: Types of Customer Replaceable Units (CRUs) installed on the storage processors.  
#>
Enum SvcCRUTypeEnum {
  SLIC = 0 #Usually, there is one or more SLIC installed on one SP.  
  SSD = 1 #Usually, there is one SSD installed on one SP.  
}

<#
  Name: SvcScopeEnum
  Description: Scope of service.  
#>
Enum SvcScopeEnum {
  system = 0 #Storage system.  
  SPA = 1 #SP A.  
  SPB = 2 #SP B.  
}

<#
  Name: ThinStatusEnum
  Description: Thin provisioning statuses for storage resource objects, as defined by storageResource type.  
#>
Enum ThinStatusEnum {
  False = 0 #The storage resource is not thin-provisioned.  
  True = 1 #The storage resource is thin-provisioned.  
  Mixed = 65535 #(Applies only to Consistency groups). If some LUNs in a Consistency group are thin-provisioned but other LUNs are not non-provisioned then the Mixed value is returned for this Consistency group. Do not use Mixed value in creation or modification requests: the storage system will respond with error.  
}

<#
  Name: ThumbprintAlgoTypeEnum
  Description: Cryptographic algorithm used to hash the public key certificate.  
#>
Enum ThumbprintAlgoTypeEnum {
  SHA = 1 #Secure Hash Algorithm (SHA).  
  SHA1 = 2 #SHA1 algorithm.  
  SHA224 = 3 #SHA2 algorithm, 224-bit.  
  SHA256 = 4 #SHA2 algorithm, 256-bit.  
  SHA384 = 5 #SHA2 algorithm, 384-bit.  
  SHA512 = 6 #SHA2 algorithm, 512-bit.  
  MD5 = 7 #MD5 algorithm.  
  RIPEMD160 = 8 #RIPEMD algorithm, 160-bit.  
  DSS1 = 9 #Digital Signature Standard (DSS) 1 algorithm.  
  Unknown = 99 #Unknown algorithm.  
}

<#
  Name: TieringPolicyEnum
  Description: Tiering policy choices for how the storage resource data will be distributed among the tiers available in the pool.  
#>
Enum TieringPolicyEnum {
  Autotier_High = 0 #The storage resource data will be initially placed on the highest available tier and then optimaly distributed over the pool's tiers by auto-tiering algorithm. <br> This is a default value for most storage resource types.  
  Autotier = 1 #The storage resource data will be optimally distributed over the pool's tiers according to the auto-tiering algorithm.  
  Highest = 2 #The storage resource data will be placed on the highest available tier.  
  Lowest = 3 #The storage resource data will be placed on the lowest available tier.  
  No_Data_Movement = 4 #The storage resource data will not be moved between pool's teirs by auto-tiering algorithm. <br> No longer supported. <br> Please specify a different tiering policy. If you use this value in Create or Modify requests, the system will return an error.  
  Mixed = 65535 #(Applies to consistency groups only.) Indicates that the LUNs contained in a consistency group have different pool tiering policies. <br> <b>Note:</b> This value applies only to the relocationPolicy attribute of the Consistency group storage resource type. <br> If you use this value in Create or Modify requests, an error will be returned.  
}

<#
  Name: TierTypeEnum
  Description: Supported pool tier types. <br/> <br/>  
#>
Enum TierTypeEnum {
  None = 0 #The disks in the storage pool has no tier type.  
  Extreme_Performance = 10 #This storage pool tier provides very fast access times for resources and subjects to variable workloads. It contains all supported Flash Disks.  
  Performance = 20 #This storage pool tier provides high throughput and good bandwidth at a mid-level price point. It contains all supported SAS disks.  
  Capacity = 30 #This storage pool tier provides the highest storage capacity with generally lower performance. It contains all supported NL-SAS disks.  
}

<#
  Name: TsCloudProviderOpStatusEnum
  Description:  
#>
Enum TsCloudProviderOpStatusEnum {
  Unknown = 0 # 
  OK = 2 # 
}

<#
  Name: UFS64TypeEnum
  Description: The types of UFS64 file system.  
#>
Enum UFS64TypeEnum {
  UFS64_Transactional = 0 #Transactional file system provisioned for VMware NFS datastores.  
  UFS64_Traditional = 1 #Traditional file system provisioned for CIFS or/and NFS accessed shared folders.  
}

<#
  Name: UnbindContextEnum
  Description:  
#>
Enum UnbindContextEnum {
  Normal = 0 # 
  RebindStart = 1 # 
  RebindEnd = 2 # 
}

<#
  Name: UncPortStatusEnum
  Description: Possible Uncommitted port statuses.  
#>
Enum UncPortStatusEnum {
  Unknown = 0 #Uncommitted port status is unknown.  
  OK = 2 #Uncommitted port status is OK.  
  Degraded = 3 #Uncommitted port status is degraded.  
  Uninitialized = 33024 #Uncommitted port status is uninitialized.  
  Empty = 33025 #Uncommitted port status is empty.  
  Missing = 33026 #Uncommitted port status is missing.  
  Faulted = 33027 #Uncommitted port status is faulted.  
  Unavailable = 33028 #Uncommitted port status is unavailabled.  
  Disabled = 33029 #Uncommitted port status is disabled.  
  SFP_Not_Present = 33280 #Uncommitted port status is SFP not present.  
  Module_Not_Present = 33281 #Uncommitted port status is module not present.  
  Port_Not_Present = 33282 #Uncommitted port status is port not present.  
  Missing_SFP = 33283 #Uncommitted port status is missing SFP.  
  Missing_Module = 33284 #Uncommitted port status is missing module.  
  Incorrect_SFP_Type = 33285 #Uncommitted port status is incorrect SFP type.  
  Incorrect_Module = 33286 #Uncommitted port status is incorrect module.  
  SFP_Read_Error = 33287 #Uncommitted port status is SFP read error.  
  Unsupported_SFP = 33288 #Uncommitted port status is unsupported SFP.  
  Module_Read_Error = 33289 #Uncommitted port status is module read error.  
  Exceeded_Maximum_Limits = 33290 #Uncommitted port status is exceeded maximum limits.  
  Module_Powered_Off = 33291 #Uncommitted port status is module powered off.  
  Unsupported_Module = 33292 #Uncommitted port status is unsupported module.  
  Database_Read_Error = 33293 #Uncommitted port status is database read error.  
  Faulted_SFP = 33294 #Uncommitted port status is faulted SFP.  
  Hardware_Fault = 33295 #Uncommitted port status is hardware fault.  
  Disabled_User_Initiated = 33296 #Uncommitted port status is disabled user initiated.  
  Disabled_Encryption_Required = 33297 #Uncommitted port status is disabled encryption required.  
  Disabled_Hardware_Fault = 33298 #Uncommitted port status is disabed hardware fault.  
}

<#
  Name: UnitEnum
  Description: The unit of measurement.  
#>
Enum UnitEnum {
  Bytes = 1 #The value is measured in bytes.  
  BytesPerSecond = 2 #The value is measured in bytes per second.  
  Percentage = 3 #The value is measured in percents.  
  Count = 4 #The value has no unit of measurement.  
  Milliseconds = 5 #The value is measured in milliseconds.  
  IOs = 6 #The value is measured in IO operations.  
  IOsPerSecond = 7 #The value is measured in IO operations per second.  
}

<#
  Name: UpdateStateEnum
  Description:  
#>
Enum UpdateStateEnum {
  Normal = 0 # 
  Unsupported = 1 # 
  Unreachable = 2 # 
}

<#
  Name: UpgradeSessionTypeEnum
  Description:  
#>
Enum UpgradeSessionTypeEnum {
  Upgrade = 0 # 
  Health_Check = 1 # 
  Storageprocessor_Upgrade = 2 # 
}

<#
  Name: UpgradeStatusEnum
  Description: Current status of the associated upgrade session.  
#>
Enum UpgradeStatusEnum {
  Upgrade_Not_Started = 0 #Upgrade session was not started.  
  Upgrade_In_Progress = 1 #Upgrade session is in the process of upgrading the system software, language pack, or drive firmware.  
  Upgrade_Completed = 2 #Upgrade session completed successfully.  
  Upgrade_Failed = 3 #Upgrade session did not complete successfully.  
  Upgrade_Failed_Lock = 4 #Upgrade session failed, and the system is in a locked state.  
  Upgrade_Cancelled = 5 #Upgrade session was cancelled.  
  Upgrade_Paused = 6 #Upgrade session is paused.  
  Upgrade_Acknowledged = 7 #Upgrade session was acknowledged.  
}

<#
  Name: UpgradeTypeEnum
  Description:  
#>
Enum UpgradeTypeEnum {
  Software = 0 # 
  Firmware = 1 # 
  LanguagePack = 2 # 
}

<#
  Name: UsageHarvestStateEnum
  Description: Pool space harvesting states.  
#>
Enum UsageHarvestStateEnum {
  Idle = 0 #Harvesting is idle and not running now.  
  Running = 1 #Harvesting is running now.  
  Could_Not_Reach_LWM = 2 #Harvesting was running but could not reach Low Watermark.  
  Paused_Could_Not_Reach_HWM = 3 #Harvesting was running but could not reach Hight Watermark and paused.  
  Failed = 4 #Harvesting was running but failed.  
}

<#
  Name: UserPasswordStateEnum
  Description: User password state  
#>
Enum UserPasswordStateEnum {
  VALID = 0 # 
  DEFAULT = 1 # 
}

<#
  Name: UserRoleEnum
  Description:  
#>
Enum UserRoleEnum {
  Administrator = 0 # 
  Storage_Administrator = 1 # 
  Vm_Administrator = 2 # 
  Operator = 3 # 
}

<#
  Name: UserTypeEnum
  Description:  
#>
Enum UserTypeEnum {
  Local_User = 0 # 
  Ldap_User = 1 # 
  Local_Group = 2 # 
  Ldap_Group = 3 # 
}

<#
  Name: VMDiskTypeEnum
  Description: Virtual Machine disk type enum returned by vSphere.  
#>
Enum VMDiskTypeEnum {
  Unknown = 0 #Virtual Machine disk type unknown.  
  VMFS_Thick = 1 #Virtual Machine disk type thick.  
  VMFS_Thin = 2 #Virtual Machine disk type thin.  
  RDM_Physical = 3 #Physical compatibility mode (pass-through) raw disk mapping. An rdmp virtual disk passes SCSI commands directly to the hardware, but the virtual disk cannot participate in snapshots. (from vSphere API description)  
  RDM_Virtual = 4 #Virtual compatibility mode raw disk mapping. An rdm virtual disk grants access to the entire raw disk and the virtual disk can participate in snapshots. (from vSphere API description)  
}

<#
  Name: VMPowerStateEnum
  Description: Power State Enum for virtual machines.  
#>
Enum VMPowerStateEnum {
  Unknown = 0 #Virtual machine power state unknown.  
  Off = 1 #Virtual machine power state off.  
  On = 2 #Virtual machine power state on.  
  Suspended = 3 #Virtual machine power state suspended.  
  Paused = 4 #Virtual machine power state paused.  
}

<#
  Name: VmwarePETypeEnum
  Description: Defines the type of VMware Protocol Endpoint.  
#>
Enum VmwarePETypeEnum {
  NAS = 0 # 
  SCSI = 1 # 
}

<#
  Name: VVolDatastoreTypeEnum
  Description: VVol datastore types.  
#>
Enum VVolDatastoreTypeEnum {
  iSCSI = 0 #LUN based VVol datastore.  
  NFS = 1 #File system based VVol datastore.  
}

<#
  Name: VVolTypeEnum
  Description: The type of VVol, for instance Config, Data, or Swap.  
#>
Enum VVolTypeEnum {
  Config = 0 #Config VVol type.  
  Data = 1 #Data VVol type.  
  Swap = 2 #Swap VVol type.  
  Memory = 3 #Memory VVol type.  
  Other = 99 #Other VVol type.  
}







# To enable debugging - Import-Module path\to\Module -ArgumentList $true

param (
    [bool]$DebugModule = $false
)

#Get Class, public and private function definition files
$Public  = @( Get-ChildItem -Path $PSScriptRoot\Public\ -Recurse -ErrorAction SilentlyContinue | Where-Object {$_.name -like '*.ps1'})
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\ -Recurse -ErrorAction SilentlyContinue | Where-Object {$_.name -like '*.ps1'})

#Dot source the files - idea from https://becomelotr.wordpress.com/2017/02/13/expensive-dot-sourcing/
Foreach($import in @($Public + $Private))
{
  If ($DebugModule) {
    Write-Verbose "Import file in debug mode: $($import.fullname)"
    . $import.fullname
  } Else {
    Try {
      Write-Verbose "Import file: $($import.fullname)"
      $ExecutionContext.InvokeCommand.InvokeScript($false, ([scriptblock]::Create([io.file]::ReadAllText($import.fullname))), $null, $null)
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
write-host " Licensed under the MIT License. (C) Copyright 2016-2017 Erwan Quelin and the community."
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
  [version]$SoftwareVersion
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

<#
  Name: Unitysystem
  Description: Information about general settings for the storage system.  
#>
Class Unitysystem {

  #Properties

  [String]$id #Unique identifier of the system instance.  
  [UnityHealth]$health #Health information for the system, as defined by the health resource type.  
  [String]$name #System name.  
  [String]$model #System model name.  
  [String]$serialNumber #System product serial number.  
  [String]$systemUUID #(Applies to virtual deployments only.) Unique system identifier required to obtain a license file for the storage system.  
  [String]$licenseActivationKey #(Applies to virtual deployments only.) Key certifies that the system is licensed and the software copy is obtained in a legal way.  
  [String]$internalModel #Internal model name for the system.  
  [String]$platform #Hardware platform for the system.  
  [String]$macAddress #MAC address of the management interface.  
  [Bool]$isEULAAccepted #Indicates whether the End User License Agreement (EULA) was accepted for an upgrade. Once the EULA is accepted, users can upload product licenses and configure the system, or both. Values are: <ul> <li>true - EULA was accepted on the system. Once you set this value, you cannot set it to false later on.</li> <li>false - EULA was not accepted on the system.</li> </ul>  
  [Bool]$isUpgradeComplete #Indicates whether an upgrade completed. Operations that change the configuration of the system are not allowed while an upgrade is in progress. <p/> Values are: <ul> <li>true - Upgrade completed.</li> <li>false - Upgrade did not complete.</li> </ul> </p> <p/>  
  [SPModelNameEnum[]]$supportedUpgradeModels #List of all supported models for hardware upgrade.
  [Int]$currentPower
  [Int]$avgPower
  [Bool]$isAutoFailbackEnabled  

  #Methods

}

Class UnityUser {
  [string]$id
  [string]$name
  $role
}

<#
  Name: Unitylun
  Description: A LUN (block storage) type storage resource, which may be a LUN in a consistency group, a standalone LUN, or a VMWare VMFS LUN. Management of LUNs is performed via the storageResource object.  
#>
Class Unitylun {

  #Properties

  [UInt64]$metadataSizeAllocated #Size of pool space allocated for the LUN's metadata.  
  [String]$snapWwn #World Wide Name of the Snap Mount Point.  
  [UInt64]$snapsSize #Size of the LUN snapshots.  
  [String]$id #Unique identifier of the LUN.  
  [UnityHealth]$health #Health information for the LUN, as defined by the health resource type.  
  [String]$name #Name of the LUN.  
  [String]$description #Description of the LUN.  
  [LUNTypeEnum]$type #Type of the LUN.  
  [UInt64]$sizeTotal #LUN size that the system presents to the host or end user.  
  [UInt64]$sizeUsed #Used size is not applicable to LUN and this value is not set.  
  [UInt64]$sizeAllocated #Size of space actually allocated in the pool for the LUN: <ul> <li>For thin-provisioned LUNs this as a rule is less than the sizeTotal attribute until the LUN is not fully populated with user data.</li> <li>For not thin-provisioned LUNs this is approximately equal to the sizeTotal.</li> </ul>  
  [UInt64]$compressionSizeSaved #Storage element saved space by inline compression  
  [Uint16]$compressionPercent #Percent compression rate  
  [Float]$compressionRatio #compression ratio  
  [Object[]]$perTierSizeUsed #Sizes of space allocations by the LUN on the tiers of multi-tier storage pool. This list will have the same length as the tiers list on this LUN's pool, and the entries will correspond to those tiers. <br> Multi-tier storage pools can be created on a system with the FAST VP license installed.  
  [Bool]$isThinEnabled #Indicates whether thin provisioning is enabled. <ul> <li>true - The LUN is thin provisioned.</li> <li>false - The LUN is not thin provisioned.</li> </ul>  
  [Bool]$isCompressionEnabled #True if compression is enabled  
  [Object]$storageResource #The storage resource with which LUN is associated.  
  [Object]$pool #The pool in which the LUN is allocated.  
  [String]$wwn #The world wide name of the LUN.  
  [TieringPolicyEnum]$tieringPolicy #(Applies if FAST VP is supported on the system and the corresponding license is installed.) FAST VP tiering policy for the LUN.  
  [NodeEnum]$defaultNode #The storage processor that is the default owner of this LUN.  
  [Bool]$isReplicationDestination #Indicates whether the LUN is a replication destination. Valid values are: <ul> <li>true - LUN is a replication destination.</li> <li>false - LUN is not a replication destination.</li> </ul>  
  [NodeEnum]$currentNode #The storage processor that is the current owner of this LUN.  
  [Object]$snapSchedule #Snapshot schedule for the LUN, as defined by the snapSchedule. This value is not set if the LUN is not associated with a snapshot schedule.  
  [Bool]$isSnapSchedulePaused #(Applies if the LUN has an associated snap schedule.) Indicates whether the snapshot schedule for the LUN is paused. Valid values are: <ul> <li>true - Snapshot schedule for the LUN is paused.</li> <li>false - Snapshot schedule for the LUN is active.</li> </ul>  
  [Object]$ioLimitPolicy #I/O limit policy that applies to the LUN, as defined by the ioLimitPolicy resource type.  
  [UInt64]$metadataSize #Size of the LUN metadata.  
  [UInt64]$snapsSizeAllocated #Size of pool space allocated for snapshots of the LUN.  
  [Object[]]$hostAccess #Host access permissions for the LUN.  
  [Int]$snapCount #Number of snapshots of the LUN.  
  [Object]$moveSession #The moveSession associated with the current lun

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

  [Bool] isExtremePerformance () {

    $ExtremePerformance = ($This.tiers | Where-Object {$_.tierType -eq 'Extreme_Performance'}).isUsed()
    $Performance = ($This.tiers | Where-Object {$_.tierType -eq 'Performance'}).isUsed()
    $Capacity = ($This.tiers | Where-Object {$_.tierType -eq 'Capacity'}).isUsed()

    Return ($ExtremePerformance -and (-not $Performance) -and (-not $Capacity))
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
  [Object[]]$poolUnits
  [Int]$diskCount

  ## Methods

  [Bool] isUsed () {
    return ($this.sizeTotal -gt 0)
  }

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

<#
  Name: UnitystorageResource
  Description: Information about storage resources in the storage system. <br/> <br/> A storage resource<b><i> </i></b>is a specific type of storage entity allocated in the storage system for a particular kind of host or application. The storage system provides the following types of storage resources: <ul> <li>LUNs</li> <li>Consistency groups</li> <li>File systems accessed via NFS and/or CIFS shares.</li> <li>VMware NFS datastores</li> <li>VMware VMFS datastores</li> <li>VVol (file)</li> <li>VVol (block)</li> </ul> All types of storage resource types can be divided into two major groups: <ul> <li>Block (or LUN based) storage resources: LUNs, consistency groups, VMware VMFS datastores, VVol (block).</li> <li>File system based storage resources: File systems, VMware NFS datastores, VVol (file).</li> </ul> In order to create a storage resource, there must be at least one pool configured on the system. For information about configuring pools, see the help topic for the pool. To provision file system based storage resource there must be at least one nasServer configured on the system.  
#>
Class UnitystorageResource {

  #Properties

  [String]$description #Storage resource description.  
  [UnityHealth]$health #Health information for the storage resource, as defined by the health type.  
  [String]$name #Name of the storage resource.  
  [String]$id #Unique identifier of the storage resource.  
  [StorageResourceTypeEnum]$type #Storage resource type.  
  [Bool]$isReplicationDestination #Indicates whether the storage resource is a replication destination. Valid values are: <ul> <li>true - Storage resource is a replication destination.</li> <li>false - Storage resource is not a replication destination.</li> </ul>  
  [ReplicationTypeEnum]$replicationType #Replication type.  
  [UInt64]$sizeTotal #Storage resource size that the system presents to the host or end user.  
  [UInt64]$sizeUsed #Size of the storage resource space consumed by the host. Applicable only for file system based storage resource. Indicates the size of file system space occupied by user files.  
  [UInt64]$sizeAllocated #Size of space actually allocated in the pool for the storage resource: <ul> <li>For all thin-provisioned resources, this can be less than the sizeTotal attribute. For a thin-provisioned file system, this can be greater than or equal to the value of the sizeUsed attribute </li> <li>For non-thin provisioned resources, this is approximately equal to the value of the sizeTotal attribute.</li> </ul>  
  [ThinStatusEnum]$thinStatus #Indicates whether the storage resource is thin-provisioned, not thin-provisioned, or mixed.  
  [CompressionStatusEnum]$compressionStatus #Compression status for the storage resource.  
  [UInt64]$compressionSizeSaved #Storage resource saved space by inline compression  
  [Uint16]$compressionPercent #Percent compression rate  
  [Float]$compressionRatio #compression ratio  
  [ESXFilesystemMajorVersionEnum]$esxFilesystemMajorVersion #(Applies to VMware VMFS storage resource type only.) VMFS major version.  
  [ESXFilesystemBlockSizeEnum]$esxFilesystemBlockSize #(Applies to VMware VMFS storage resource type only.) VMFS block size. Only applies to storage resources with VMFS major version 3.  
  [Object]$snapSchedule #Snapshot schedule for the storage resource, as defined by the snapSchedule This value is not set if the storage resource is not associated with a snapshot schedule.  
  [Bool]$isSnapSchedulePaused #(Applies if the storage resource has an associated snap schedule.) Indicates whether the snapshot schedule for the storage resource is paused. Valid values are: <ul> <li>true - Snapshot schedule for the storage resource is paused.</li> <li>false - Snapshot schedule for the storage resource is active.</li> </ul>  
  [TieringPolicyEnum]$relocationPolicy #(Applies if FAST VP is supported on the system and the corresponding license is installed.) FAST VP tiering policy for the storage resource.  
  [Object[]]$perTierSizeUsed #Sizes of space allocations by the storage resource per tiers of the multi-tier storage pool. Multi-tier storage pools can be created on the system when the FAST VP license is installed.  
  [Object[]]$blockHostAccess #Host access permissions for a block storage resource types, as defined by the blockHostAccess resource type.  
  [UInt64]$metadataSize #Size of the storage resource metadata.  
  [UInt64]$metadataSizeAllocated #Size of pool space allocated for the storage resource metadata.  
  [UInt64]$snapsSizeTotal #Size of the storage resource snapshots.  
  [UInt64]$snapsSizeAllocated #Size of pool space allocated for storage resource snapshots.  
  [Int]$snapCount #Number of storage resource snapshots.  
  [String]$vmwareUUID #VMware UUID of the VVol datastore assigned by VMware ESX hypervisor (Applies to VMware VVol datastore resources only.).  
  [Object[]]$pools #List of pools associated with this storage resource. LUNs in a consistency group storage resource can be allocated from different pools.  
  [Object[]]$datastores #The datastores associated with the current storageResource
  [Object]$filesystem #The filesystem associated with the current storageResource
  [Object[]]$hostVVolDatastore #The hostVVolDatastores associated with the current storageResource
  [Object[]]$luns #The luns associated with the current storageResource
  [Object[]]$moves #The moveSessions associated with the current storageResource
  [Object[]]$virtualVolumes #The virtualVolumes associated with the current storageResource

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

<#
  Name: UnitynasServer
  Description: Information about the NAS server in the storage system. <br/> <br/> NAS Servers are software components used to transfer data and provide the connection ports for hosts to access file-level storage resources. NAS servers are independent from each other. <br/> <br/> NAS Servers access data on available drives making it available to network hosts via specific protocols (NFS/SMB/FTP/SFTP). Storage system supports NAS Servers for managing file-level storage resources, such as VMware NFS datastores or file systems. <br/> Before you can provision a file-level storage resource, a NAS Server must be created with the necessary sharing protocols enabled. When NAS Servers are created, you can specify the storage pool and owning SP - either SPA or SPB. <br/> In the storage systems, NAS Servers can leverage the Link Aggregation functionality to create a highly available environment. Once a link aggregated port group is available, you create or modify NAS Server network interfaces to leverage the available port group. Because NAS Servers are accessible through only one SP at a time, they will fail over to the other SP when there is an SP failure event.  
#>
Class UnitynasServer {

  #Properties

  [String]$id #Unique identifier of the nasServer instance.  
  [String]$name #User-specified name of the NAS server.  
  [UnityHealth]$health #Health information for the NAS server, as defined by the health resource type.  
  [Object]$homeSP #Storage Processor on which the NAS Server is intended to run.  
  [Object]$currentSP #Storage Processor on which the NAS server is currently running.  
  [Object]$pool #Storage pool that stores the NAS server's configuration metadata, as defined by the pool resource type.  
  [Long]$sizeAllocated #Amount of storage pool space used for NAS server configuration.  
  [Object]$tenant #Tenant to which the NAS Server belongs.  
  [Bool]$isReplicationEnabled #Indicates whether a replication session is enabled for the NAS server. The NAS server can't be deleted while replication session is enabled. Values are: <ul> <li> true - Replication session is enabled. </li> <li> false - Replication session is disabled. </li> </ul>  
  [Bool]$isReplicationDestination #Indicates whether the NAS server is a replication destination. Values are: <ul> <li>true - NAS server is a replication destination.</li> <li>false - NAS server is a not a replication destination.</li> </ul>  
  [Bool]$isMigrationDestination #Indicates whether the NAS server is a migration destination. It can't be modified by client. Values are: <ul> <li>true - NAS server is a migration destination.</li> <li>false - NAS server is a not a migration destination.</li> </ul>  
  [ReplicationTypeEnum]$replicationType #Replication type.  
  [String]$defaultUnixUser #Default Unix user name to use for an unmapped Windows user. This value only applies when the value of allowUnmappedUser is true.  
  [String]$defaultWindowsUser #Default Windows user name to use for an unmapped Unix user. This value only applies when the value of allowUnmappedUser is true.  
  [NasServerUnixDirectoryServiceEnum]$currentUnixDirectoryService #Unix Directory Service used to look up users and hosts.  
  [Bool]$isMultiProtocolEnabled #Indicates whether multiprotocol sharing mode is enabled. This mode enables simultaneous file access for Windows and Unix users. Values are: <ul> <li> true - Multiprotocol sharing mode is enabled. </li> <li> false - Multiprotocol sharing mode is disabled. </li> </ul>  
  [Bool]$isWindowsToUnixUsernameMappingEnabled #Indicates whether a Unix to/from Windows user name mapping is enabled. Values are: <ul> <li> true - Unix to/from Windows user name mapping is enabled. </li> <li> false - Unix to/from Windows user name mapping is disabled. </li> </ul>  
  [Bool]$allowUnmappedUser #Indicates whether an unmappped user can access the NAS server as a default user. Values are: <ul> <li> true - Allow access for unmapped users. </li> <li> false - Disallow access for unmapped users. </li> </ul>  
  [Bool]$isPacketReflectEnabled #Indicates whether the reflection of outbound (reply) packets through the same interface that inbound (request) packets entered is enabled. Values are: <ul> <li> true - (Default) Packet Reflect is enabled. </li> <li> false - Packet Reflect is disabled. </li> </ul>  
  [Object[]]$cifsServer #The cifsServers associated with the current nasServer
  [Object]$fileDNSServer #The fileDNSServer associated with the current nasServer
  [Object]$eventPublisher #The fileEventsPublisher associated with the current nasServer
  [Object[]]$fileInterface #The fileInterfaces associated with the current nasServer
  [Object]$nfsServer #The nfsServer associated with the current nasServer
  [Object]$preferredInterfaceSettings #The preferredInterfaceSettings associated with the current nasServer
  [Object]$virusChecker #The virusChecker associated with the current nasServer

  #Methods

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

Class Unityfilesystem {

  #Properties

  [String]$id #Unique identifier of the file system.  
  [UnityHealth]$health #Health information for the file system, as defined by the health resource type.  
  [String]$name #File system name unique to the NAS server.  
  [String]$description #File system description.  
  [FilesystemTypeEnum]$type #File system type.  
  [UInt64]$sizeTotal #File system size that the system presents to the host or end user.  
  [UInt64]$sizeUsed #Size of used space in the file system by the user files.  
  [UInt64]$sizeAllocated #Size of pool space allocated for the file system: <ul> <li>For a thin-provisioned file system, this as a rule is less than the value of the sizeTotal attribute and slightly greater than or equal to the value of the sizeUsed attribute.</li> <li>For a not thin-provisioned file system, this is approximately equal to the value of the attribute sizeTotal.</lki> </ul> This measurement does not include space reserved for snapshots.  
  [UInt64]$minSizeAllocated #<ul> <li>For a thin-provisioned file system, this is the minimum allocated size to which the file system can be auto-shrunk.</li> <li>This attribute does not apply for a thick-provisioned file system</li> </ul> This measurement does not include space reserved for snapshots.  
  [Bool]$isReadOnly #Indicates whether the file system is read-only. Values are: <ul> <li>true - File system is read-only.</li> <li>false - File system is read-write.</li> </ul>  
  [Bool]$isThinEnabled #Indicates whether the file system is thin-provisioned. Values are: <ul> <li>true - File system is thin-provisioned.</li> <li>false - File system is thick-provisoned.</li> </ul>  
  [Object]$storageResource #Storage resource to which the file system belongs, as defined by the storageResource.  
  [Bool]$isCIFSSyncWritesEnabled #(SMB (also known as CIFS) file systems) Indicates whether the synchronous writes option is enabled on the file system. Values are: <ul> <li>true - Synchronous writes option is enabled on the file system.</li> <li>false - Synchronous writes option is disabled on the file system.</li> </ul>  
  [Object]$pool #Storage pool in which file system is allocated, as defined by the pool object.  
  [Bool]$isCIFSOpLocksEnabled #(SMB (also known as CIFS) file systems) Indicates whether opportunistic file locking is enabled on the file system. Values are: <ul> <li>true - Opportunistic file locking is enabled on the file system.</li> <li>false - Opportunistic file locking is disabled on the file system.</li> </ul>  
  [Object]$nasServer #NAS server that provides network connectivity to the file system from the hosts.  
  [Bool]$isCIFSNotifyOnWriteEnabled #(SMB (also known as CIFS) file systems) Indicates whether notifications on file writes are enabled on the file system. Values are: <ul> <li>true - Notifications on file writes are enabled on the file system.</li> <li>false - Notifications on file writes are disabled on the file system.</li> </ul>  
  [Bool]$isCIFSNotifyOnAccessEnabled #(SMB (also known as CIFS) file systems) Indicates whether notifications on file access are enabled on the file system. Values are: <ul> <li>true - Notifications on file access are enabled on the file system.</li> <li>false - Notifications on file access are disabled on the file system.</li> </ul>  
  [UInt16]$cifsNotifyOnChangeDirDepth #(SMB (also known as CIFS) file systems) Lowest directory level to which the enabled notifications apply, if any.  
  [DedupStateEnum]$dedupState #File system deduplication state.  
  [String[]]$dedupExcludePaths #Paths excluded from deduplication.  
  [String[]]$dedupExcludeExtensions #File extensions excluded from deduplication.  
  [Bool]$isDedupRunning #Indicates whether deduplication is running on the file system. Values are: <ul> <li>true - Deduplication is running on the file system.</li> <li>false - Deduplication is not running on the file system.</li> </ul>  
  [DateTime]$dedupLastScan #Date and time of the last full deduplication scan of the file system.  
  [UInt64]$dedupOriginalSizeUsed #File system size without deduplication.  
  [UInt64]$dedupSizeUsed #File system size with deduplication.  
  [UInt64]$dedupSizeSaved #Size of pool space saved by deduplication.  
  [UInt64]$dedupPercentSaved #Percentage of space saved by deduplication.  
  [UInt64]$dedupNumFilesTotal #Total number of regular and deduplicated files in the file system, as detected in last successful deduplication scan.  
  [UInt64]$dedupNumFilesDeduped #Number of deduplicated files in the file system, as detected by the last successful deduplication scan.  
  [UInt64]$dedupNumFilesScanned #(Applies when deduplication is enabled and running.) Number of files scanned so far in the deduplication scan of the file system.  
  [UInt64]$dedupNumFileRecalled #(Applies when deduplication is enabled and running.) Number of files recalled during the latest deduplication process.  
  [UInt16]$dedupProgress #(Applies when deduplication is enabled.) Percent of the deduplication process that was completed.  
  [TieringPolicyEnum]$tieringPolicy #(Applies if a FAST VP license is installed.) FAST VP tiering policy for the file system.  
  [FSSupportedProtocolEnum]$supportedProtocols #Protocols supported by the file system.  
  [UInt64]$metadataSize #Size of file system metadata.  
  [UInt64]$metadataSizeAllocated #Size of pool space allocated for file system metadata.  
  [UInt64[]]$perTierSizeUsed #Sizes of space allocations by the file system on the tiers of multi-tier storage pool. This list will have the same length as the tiers list on this file system's pool, and the entries will correspond to those tiers. <br> Multi-tier storage pools can be created on a system with the FAST VP license installed.  
  [UInt64]$snapsSize #Size of space used by file system snapshots.  
  [UInt64]$snapsSizeAllocated #Size of pool space allocated for file system snapshots.  
  [Int]$snapCount #Number of file system snapshots.  
  [Bool]$isSMBCA #Indicates whether or not SMB 3.0 is enabled. Values are: <ul> <li>true - SMB 3.0 is enabled.</li> <li>false - SMB 3.0 is disabled.</li> </ul>  
  [AccessPolicyEnum]$accessPolicy #Access policies which are supported by file system.  
  [FSRenamePolicyEnum]$folderRenamePolicy #Rename policies which are supported by file system. These policy choices control whether directory can be renamed from NFS or SMB clients if at least one file is opened in the directory or in one of its children directory.  
  [FSLockingPolicyEnum]$lockingPolicy #Locking policies which are supported by file system. These policy choices control whether the NFSv4 range locks must be honored. Because NFSv3 is advisory by design, this policy allows specifying whether the NFSv4 locking feature behaves like NFSv3 in order to be backward compatibilty with applications expecting an advisory locking scheme.  
  [FSFormatEnum]$format #File system format.  
  [HostIOSizeEnum]$hostIOSize #Typical write I/O size from the host to the file system.  
  [ResourcePoolFullPolicyEnum]$poolFullPolicy #File system behavior to follow when pool is full and a write to this filesystem is attempted.  
  [Object]$fileEventSettings #Indicates whether File Event Service is enabled for some protocols on the filesystem.  
  [Object[]]$cifsShare #The cifsShares associated with the current filesystem
  [Object[]]$nfsShare #The nfsShares associated with the current filesystem

  #Methods

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

<#
  Name: Unitydisk
  Description: Information about the disks's attributes in the storage system. <br/> <br/>  
#>
Class Unitydisk {

  #Properties

  [String]$id #Unique identifier of the disk instance.  
  [UnityHealth]$health #Health information of the disk instance as defined by the health resource type.  
  [Bool]$needsReplacement #Indicates whether disk replacement is needed. Values are: <ul> <li> true - Disk replacment is needed.</li> <li>false - No disk replacement is needed.</li> </ul>  
  [Object]$parent #Resource type and unique identifier for the disk's parent enclosure.  
  [Int]$slotNumber #Slot where the disk is located in the parent enclosure.  
  [DateTime]$estimatedEOL #Estimated remaning life of disk, based on past use. Applies only to flash disks.  
  [Int]$busId #Identifier of the bus used by the disk.  
  [String]$name #Disk name. Modifiable for virtual disks only.  
  [String]$manufacturer #Disk manufacturer.  
  [String]$model #Manufacturer model number.  
  [String]$version #Manufacturer version number.  
  [String]$emcPartNumber #EMC part number.  
  [String]$emcSerialNumber #EMC serial number.  
  [TierTypeEnum]$tierType #Disk type.  
  [Object]$diskGroup #Disk group is the group that the disk belongs to and as defined by the diskGroup resource type.  
  [Int]$rpm #Revolutions Per Minute (RPMs).  
  [Bool]$isSED #Indicates whether the disk is a Self-Encrypting Drive (SED). <ul> <li> true - Disk is a SED. </li> <li>false - Disk is not a SED.</li> </ul>  
  [Long]$currentSpeed #Current speed.  
  [Long]$maxSpeed #Maximum speed.  
  [Object]$pool #Pool that the disk belongs, as defined by the pool resource type.  
  [Bool]$isInUse #Indicates whether the disk contains user-written data. Values are: <ul> <li> true - Disk contains user-written data.</li> <li>false - Disk does not contain user-written data.</li> </ul>  
  [Bool]$isFastCacheInUse #(Applies if FAST Cache is supported on the system and the corresponding license is installed.) Indicates whether the disk is used by the FAST Cache. Values are: <ul> <li> true - Disk is used by the FAST Cache.</li> <li>false - Disk is not used by the FAST Cache.</li> </ul>  
  [Long]$size #Usable capacity.  
  [Long]$rawSize #Raw (unformatted) capacity.  
  [Long]$vendorSize #Vendor capacity of the disk as written on the disk label.  
  [String]$wwn #World Wide Name (WWN) of the disk.  
  [DiskTechnologyEnum]$diskTechnology #Disk technology.  
  [Object]$parentDae #Parent Disk Array Enclosure (DAE) of the disk as defined by the dae resource type.  
  [Object]$parentDpe #Parent Disk Processor Enclosure (DPE) of the disk, as defined by the dpe resource type.  
  [String]$bank #Bank where the disk is located in the parent enclosure.  
  [Int]$bankSlotNumber #Bank slot where the disk is located in the parent enclosure.  
  [String]$bankSlot #Combination of the bank and slot name where the disk is located in the parent enclosure.  

  #Methods

}

Class UnityHealth {
  [HealthEnum]$value
  [System.Array]$descriptionIds
  [System.Array]$descriptions
  [System.Array]$resolutionIds
  [System.Array]$resolutions
}

<#
  Name: Unityhost
  Description: Information about host configuration on a storage system. A host's configuration is the logical connection through which the host or application can access storage resources. <br/> <br/>  
#>
Class Unityhost {

  #Properties

  [Object]$hostContainer #(Applies to VCenter server and ESX host configurations only.) Identifier of the parent host container, as defined by the hostContainer resource type.  
  [String]$id #Unique identifier of the host instance.  
  [UnityHealth]$health #Health information for the host, as defined by the health resource type.  
  [String]$name #Host name: <ul> <li>For an automatically-managed ESX server through vCenter, this is the display name in the vCenter GUI.</li> <li>For a manually-created host, this is the host name entered by the user.</li> </ul>  
  [String]$description #Host description.  
  [HostTypeEnum]$type #Type of host configuration.  
  [String]$osType #Operating system running on the host.  
  [String]$hostUUID #(Applies to VCenter server and ESX host configurations only.) Universal Unique Identifier (UUID) of the host.  
  [String]$hostPushedUUID #(Applies to VCenter server and ESX host configurations only.) Pushed UUID of the host.  
  [String]$hostPolledUUID #(Applies to VCenter server and ESX host configurations only.) Polled UUID of the host.  
  [DateTime]$lastPollTime #(Applies to hosts on ESX servers only.) Indicates the date and time when the storage array received the host configuration data from the ESX server.  
  [HostManageEnum]$autoManageType #Indicates how the host is managed.  
  [HostRegistrationTypeEnum]$registrationType #Indicates how initiators are registered to the host.  
  [Object[]]$fcHostInitiators #Identifiers of the Fibre Channel initiators associated with the host, as defined by the hostInitiator resource type.  
  [Object[]]$iscsiHostInitiators #Identifiers of the iSCSI initiators associated with the host, as defined by the hostInitiator resource type.  
  [Object[]]$hostIPPorts #Identifiers of the network ports associated with the host, as defined by the hostIPPort resource type.  
  [Object[]]$storageResources #Identifiers of the storage resources used by the host, as defined by the storageResource resource type.  
  [Object[]]$hostLUNs #(Applies to iSCSI and Fibre Channel host configurations only.) Identifiers of the LUNs accessible by the host, as defined by the hostLUN resource type.  
  [Object]$tenant #Information about the tenant to which the host is assigned.  
  [Object[]]$datastores #The datastores associated with the current host
  [Object[]]$hostVVolDatastore #The hostVVolDatastores associated with the current host
  [Object[]]$vms #The vms associated with the current host

  #Methods

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

Class UnityalertConfig {

  #Properties

  [String]$id #Unique identifier of the alertConfig instance. This value is always 0, because there is only one occurrence of this resource type.  
  [LocaleEnum]$locale #Language in which the system sends email alerts.  
  [Bool]$isThresholdAlertsEnabled #Indicates whether pool space usage percent threshold alerts functionality is enabled, notice that this flag will be ignored and alerts will be sent always when it is thin provisioned and oversubscribed. Values are: <br/> <br/> <ul> <li>true - The pool space usage related alerts will be shown to the user when pool space usage percent reaches the threshold.</li> <br/> <br/> <li>false - The pool space usage related alerts will not be shown to the user when pool space usage percent reaches the threshold.</li> </ul>  
  [SeverityEnum]$minEmailNotificationSeverity #Minimum severity level for email alerts.  
  [String]$emailFromAddress #The email from address which is used when sending alert emails.  
  [String[]]$destinationEmails #A list of emails to receive alert notifications.  
  [SeverityEnum]$minSNMPTrapNotificationSeverity #Minimum severity level for SNMP trap alerts.  

  #Methods

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

<#
  Name: Unitysnap
  Description: Information about storage resource snapshots in the storage system.  
#>
Class Unitysnap {

  #Properties

  [String]$id #Unique identifier of the snap instance.  
  [String]$name #Snapshot name.  
  [String]$description #Snapshot description.  
  [Object]$storageResource #Storage resource for which the snapshot was taken as defined by the storageResource resource type.  
  [Object]$lun #For a snapshot of a LUN in a Consistency group, the unique identifier of the source LUN as defined by the lun resource type.  
  [Object]$snapGroup #For a snapshot of a LUN in a Consistency group, the unique identifier of the snapshot group to which the snapshot belongs, as defined by the snap resource type.  
  [Object]$parentSnap #For a snapshot of another snapshot, the unique identifier of the parent snapshot, as defined by the snap resource type.  
  [DateTime]$creationTime #Date and time on which the snapshot was taken.  
  [DateTime]$expirationTime #Date and time after which the snapshot will expire.  
  [DateTime]$lastRefreshTime #Date and time of last refresh operation  
  [SnapCreatorTypeEnum]$creatorType #Type of creator that created this snapshot.  
  [Object]$creatorUser #For a user-created snapshot, information about the user that created the snapshot, as defined by the user resource type.  
  [Object]$creatorSchedule #For a schedule-created snapshot, information about the snapshot schedule that created the snapshot, as defined by the snapSchedule resource type.  
  [Bool]$isSystemSnap #Indicates whether the snapshot is an internal snapshot. Internal snapshots are created by the Replication feature. End user operations are not permitted on internal snapshots. Values are: <ul> <li>true - Snapshot is internal.</li> <li>false - Snapshot is external.</li> </ul>  
  [Bool]$isModifiable #Indicates whether the snapshot is attached or created with protocol access in a manner making it writable by clients. Values are: <ul> <li>true - Snapshot can be modified.</li> <li>false - Snapshot cannot be modified.</li> </ul> Snapshots of file systems and VMware NFS datastores are modifiable when they are created with protocol access. Snapshots of LUNs and VMware VMFS datastores are modifiable when they are attached.  
  [String]$attachedWWN #For an attached snapshot, the World Wide Name (WWN) of the attached LUN.  
  [FilesystemSnapAccessTypeEnum]$accessType #For a file system or VMware NFS datastore snapshot, indicates whether the snapshot has checkpoint or protocol type access.  
  [Bool]$isReadOnly #Indicates whether the snapshot was created with read-only (checkpoint) access (file system or VMware NFS datastore snapshots only). Values are: <ul> <li>true - Snapshot was created with read-only (checkpoint) access and cannot be modified.</li> <li>false - Snapshot was created with read-write (protocol) access and can be modified.</li> </ul>  
  [DateTime]$lastWritableTime #If not attached or shared, and was attached or shared in the past, time of last unattach or share deletion.  
  [Bool]$isModified #Indicates if the snapshot may have changed since it was created. Values are: <ul> <li>true - Snapshot is or was attached or it was created with protocol access.</li> <li>false - Snapshot was never attached or it was created with checkpoint access.</li> </ul>  
  [Bool]$isAutoDelete #Indicates if this snapshot can be automatically deleted by the system per threshold settings. Values are: <ul> <li>true - Snapshot can be automatically deleted by the system per threshold settings.</li> <li>false - Snapshot cannot be deleted automatically.</li> </ul>  
  [SnapStateEnum]$state #The snapshot state in Snapshot state enum.  
  [Uint64]$size #Size of the storage resource when the snapshot was created (LUN snapshots only).  
  [Object]$ioLimitPolicy #IO limit policy that applies to the snapshot, as defined by the ioLimitPolicy resource type.  
  [Object[]]$hostAccess #(LUN, LUN Group and VMware VMFS datastore snapshots only). Host access permissions for snapshot, as defined by the snapHostAccess resource type. Value is set only if snapshot is attached to dynamic Snapshot Mount Point.  

  #Methods

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

<#
  Name: Unitymetric
  Description: One of the following: <ul> <li>Performance measurements for the Unity system.  
#>
Class Unitymetric {

  #Properties

  [Int]$id #Unique identifier for the metric instance.  
  [String]$name #Display name of the metric.  
  [String]$path #Stat paths for the historical and real-time metrics. A stat path identifies a metric's location in the stats namespace. There are two types of stat paths: <ul> <li> stat paths for historical metrics</li> <li> Stat paths for real-time metrics</i> </ul> <br/> <b>stat paths for historical metrics</b> Use the following URI pattern to retrieve stat paths for all historical metrics: <br/> <br/> <span class=EMCCode>/api/types/metric/instances?compact=true&filter=isHistoricalAvailable eq true </span> <br/> <br/> <b>Stat path for real-time metrics</b> <br/> <br/> Use the following URI pattern to retrieve stat paths for all real-time metrics: <br/> <br/> <span class=EMCCode>/api/types/metric/instances?compact=true&filter=isRealtimeAvailable eq true </span> <br/> <br/> For both historical and real-time quey, the following URI pattern can be used to retrieve stat paths for a group of metrics. In this pattern, %25 is an encoded value for a percent sign (%). <br/> <br/> <span class=EMCCode>/api/types/metric/instances?compact=true&filter=path lk <i>metric-path</i>.%25</span> <br/> <br/> where <i>metric-path</i> is one of the stat paths listed below: <ul> <li>sp.*.blockCache - Counters for cache metrics</li> <li>sp*.cifs - CIFS protocol statistics</li> <li>sp.*.fibreChannel - Fibre Channel statistics</li> <li>sp.*.fs - File system statistics</li> <li>sp.*.ftp - FTP protocol statistics</li> <li>sp.*.http - HTTP protocol statistics</li> <li>sp.*.iscsi - iSCSI protocol statistics</li> <li>sp.*.memory - Memory statistics</li> <li>sp.*.ndmp - NDMP protocal statistics</li> <li>sp.*.cpu - CPU statistics</li> <li>sp.*.net - Network interface and protocol statistics</li> <li>sp.*.nfs - NFS protocol statistics</li> <li>sp.*.ntp - NTP statistics</li> <li>sp.*.physical - Physical device statistics</li> <li>sp.*.replication - Replication statistics</li> <li>sp.*.rpc - RPC statistics</li> <li>sp.*.ssh - SSH statistics</li> <li>sp.*.store - Storage hardware interface statistics</li> <li>sp.*.storage - Storage statistics</li> <li>sp.*.vhdx - Microsoft Hyper-V virtual disks statistics</li> <li>sp.*.virusChecker - Virus checker statistics</li> </ul> <br/> <br/> For example, to retrieve a list of available network performance metrics, you can use the following GET collection request: <br/> <br/> <span class=EMCCode>https://<i>ip-address</i>/api/types/metric/instances?compact=t rue&filter=path lk sp.*.net.%25</span>  
  [Int]$product #Product that supports the metric. Values are: <ul> <li>0 - VNXe</li> <li>1 - VNX</li> <li>2 - Iomega</li> </ul>  
  [Int]$type #Type of metric. Values are: <ul> <li>2 - 32 bits counter</li> <li>3 - 64 bits counter</li> <li>4 - rate</li> <li>5 - fact</li> <li>6 - text</li> <li>7 - 32 bits virtual counter</li> <li>8 - 64 bits virtual counter</li> </ul>  
  [Int]$objectType #Type of object associated with the metric. Values are: <ul> <li>0 - lun</li> <li>1 - sp</li> <li>2 - pool</li> <li>3 - volume</li> <li>4 - filesys</li> <li>5 - port </li> <li>6 - disk</li> <li>7 - cpu</li> <li>8 - dm</li> <li>9 - enclosure</li> <li>10 - tier</li> <li>11 - sg</li> </ul>  
  [String]$description #Short description of the metric.  
  [Bool]$isHistoricalAvailable #Indicates whether the metric is available for historical collection: <ul> <li>true - Metric is supported for historical collection. <li>false - Metric is not supported for historical collection. </ul>  
  [Bool]$isRealtimeAvailable #Indicates whether the metric is supported for real-time collection: <ul> <li> true - Metric is supported for real-time collection. <li>false - Metric is not supported for real-time collection. </ul>  
  [String]$unitDisplayString #Localized text used to describe the metric unit.  

  #Methods

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

<#
  Name: UnityhostInitiator
  Description: Information about host initiators in the storage system. <br/> <br/> After you create a host configuration for controlling host access to storage on the system, you need to create a host initiator for each host configuration that accesses iSCSI or Fibre Channel (FC) storage. The initiator connects the host to the target iSCSI or FC node on the system. <br/> <br/> Initiator-based registration allows you to register the initiator to a host without having to manage individual paths. By default, when an initiator is registered to a host, all of its paths, including those specified after the registration takes place, are automatically granted access to any storage provisioned for the host. <br/>  
#>
Class UnityhostInitiator {

  #Properties

  [String]$id #Unique identifier of the hostInitiator instance.  
  [UnityHealth]$health #Health information for the host initiator, as defined by the health resource type.  
  [HostInitiatorTypeEnum]$type #Host initiator type.  
  [String]$initiatorId #Host initiator name: <ul> <li>For an iSCSI initiator, this is the iSCSI Qualified Name (IQN). </li> <li>For an FC initiator, this is the Worldwide Name (WWN).</li> </ul>  
  [Object]$parentHost #Information about the host to which the host initiator is assigned, as defined by the host resource type.  
  [Bool]$isIgnored #Indicates whether the host initiator should be included when storage access is granted to the host. Values are: <ul> <li>true - Do not include the host initiator when storage is granted to the associated host.</li> <li>false - Include the host initiator when storage is granted to the associated host.</li> </ul>  
  [String]$nodeWWN #(Applies to FC initiators only.) Node Worldwide Name (WWN) of the initiator.  
  [String]$portWWN #(Applies to FC initiators only.) Port Worldwide Name (WWN) of the initiator.  
  [String]$chapUserName #(Applies to iSCSI initiators only.) CHAP user name. By default, this is the host initiator's iSCSI Qualified Name (IQN).  
  [Bool]$isChapSecretEnabled #(Applies to iSCSI initiators only.) Indicates whether CHAP authentication is enabled for the host initiator. Values are: <ul> <li>true - CHAP authentication is enabled.</li> <li>false - CHAP authentication is disabled.</li> </ul>  
  [Object[]]$paths #Host initiator paths, as defined by the hostInitiatorPath resource type.  
  [HostInitiatorIscsiTypeEnum]$iscsiType #(Applies to iSCSI initiators only.) iSCSI initiator type.  
  [Bool]$isBound #(Applies to iSCSI initiators only.) Indicates whether the iSCSI initiator is bound to an IP address. This is only applicable to hardware-dependent adapter devices. Values are: <ul> <li>true - iSCSI initiator is bound to an IP address.</li> <li>false - iSCSI initiator is not bound to an IP address.</li> </ul>  
  [HostInitiatorSourceTypeEnum]$sourceType #Initiator source type.  

  #Methods

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



###Classes added automatically

#START
<#
  Name: UnityaclUser
  Description: A user associated with a CIFS share level ACL.  
#>
Class UnityaclUser {

  #Properties

  [String]$id #Unique instance id.  
  [String]$sid #Windows user id.  
  [String]$domainName #Windows domain name.  
  [String]$userName #User name.  

  #Methods

}

<#
  Name: UnityaffectedResource
  Description: affectedResource is a resource entity affected by a job instance.  
#>
Class UnityaffectedResource {

  #Properties

  [String]$resource #The resource name of the referenced instance (for GUI navigation).  
  [String]$id #The id of the referenced instance.  
  [String]$name #The name of the reference instance, if applicable.  

  #Methods

}

<#
  Name: UnityalertConfigSNMPTarget
  Description: Information about the Simple Network Management Protocol (SNMP) destinations used by alerts. <br/> The system uses SNMP to transfer system alerts as traps to an SNMP destination host. Traps are asynchronous messages that notify the SNMP destination when system and user events occur.  
#>
Class UnityalertConfigSNMPTarget {

  #Properties

  [String]$id #Unique identifier of the alertConfigSNMPTarget instance.  
  [Object]$address #Host address and port for the SNMP destination. The default UDP port number is 162.  
  [SNMPVersionEnum]$version #SNMP version used to send the traps or informs.  
  [String]$username #Username used to access the SNMP destination.  
  [SNMPAuthProtocolEnum]$authProto #Protocol used to authenticate access to the SNMP destination.  
  [SNMPPrivacyProtocolEnum]$privacyProto #Protocol used to enable privacy on the SNMP destination. The privacy protocol encrypts the SNMP packets.  

  #Methods

}

<#
  Name: UnitybaseRequest
  Description: This object is used to represent a generic POST request action. It contains different set of strongly typed properties for different concrete actions.  
#>
Class UnitybaseRequest {

  #Properties


  #Methods

}

<#
  Name: UnitybaseResponse
  Description: This is used to represent a generic method response. It contains different set of strongly typed properties for different actions.  
#>
Class UnitybaseResponse {

  #Properties


  #Methods

}

<#
  Name: UnityblockHostAccess
  Description: Host access settings for the storage resource. <br/> <br/> This resource type is embedded in the storageResource resource type.  
#>
Class UnityblockHostAccess {

  #Properties

  [Object]$host #Host associated with the storage resource, as defined by the host resource type.  
  [HostLUNAccessEnum]$accessMask #Host access permissions.  
  [BlockHostAccessEnum]$productionAccess #Production LUN(s) access mask.  
  [BlockHostAccessEnum]$snapshotAccess #Snapshot LUN(s) access mask.  

  #Methods

}

<#
  Name: UnityblockHostAccessParam
  Description: Host access settings for changing host access of LUNs. <br/> <br/> This resource type is embedded in the lunParameters embedded type.  
#>
Class UnityblockHostAccessParam {

  #Properties

  [Object]$host #Host to grant access to LUN, as defined by host type.  
  [HostLUNAccessEnum]$accessMask #Host access mask.  

  #Methods

}

<#
  Name: UnitycandidateSoftwareVersion
  Description: Information about system software upgrades and language packs uploaded to the storage system and available to install.  
#>
Class UnitycandidateSoftwareVersion {

  #Properties

  [String]$id #Unique identifier of the candidateSoftwareVersion instance.  
  [String]$version #Version of the candidate software.  
  [Object]$revision #Revision number of the candidate software.  
  [DateTime]$releaseDate #Release date of the candidate software.  
  [UpgradeTypeEnum]$type #Type of the candidate software.  
  [Bool]$rebootRequired #Package requires reboot of bo5th SPs, one at a time, with services remaining available.  
  [Bool]$canPauseBeforeReboot #Package can utilize the 'pause' feature allowing the user to choose their disruptive window.  

  #Methods

}

<#
  Name: UnitycapabilityProfile
  Description: An object representing VASA 2.0 SPBM capability profile. Capability profiles can be queried, created, modified and deleted via the REST API. Capability profiles can then be queried via VASA 2.0 API by vSphere environment and leveraged for policy based provisioning of virtual volumes.  
#>
Class UnitycapabilityProfile {

  #Properties

  [String]$id #Unique identifier of the capability profile.  
  [String]$vmwareUUID #Automatically generated unique identifier of the capability profile exposed via VASA 2.0 protocol. It will conform to RFC 3151 section 1.1.  
  [String]$name #The name of the capability profile.  
  [String]$description #Capability profile description.  
  [Object]$pool #The storage pool the capability profile is associated with.  
  [DiskTierEnum[]]$driveTypes #Supported drive types for the capability profile.  
  [FastCacheStateEnum[]]$fastCacheStates #Supported fast cache states for the capability profile.  
  [RaidTypeEnum[]]$raidTypes #Supported RAID types for the capability profile.  
  [SpaceEfficiencyEnum[]]$spaceEfficiencies #Supported space efficiency choices for the capability profile.  
  [TieringPolicyEnum[]]$tieringPolicies #Supported tiering policies for the capability profile.  
  [ServiceLevelEnum[]]$serviceLevels #Supported service level for the capability profile.  
  [String[]]$usageTags #Associated usage tags for the capability profile.  
  [Bool]$inUse #Whether any virtual volumes have been created using this capability profile.  
  [UnityHealth]$health #Health information for the capability profile, as defined by the health resource type.  
  [Object[]]$virtualVolumes #The virtualVolumes associated with the current capabilityProfile

  #Methods

}

<#
  Name: UnitycapabilityProfileRecommendation
  Description: An entity representing a recommendation for a VASA 2.0 SPBM capability profile.  
#>
Class UnitycapabilityProfileRecommendation {

  #Properties

  [DiskTierEnum[]]$driveTypes #List of drive types for individual capabilities.  
  [FastCacheStateEnum[]]$fastCacheStates #List of fast cache states for individual capabilities.  
  [RaidTypeEnum[]]$raidTypes #List of RAID types for individual capabilities.  
  [SpaceEfficiencyEnum[]]$spaceEfficiencies #List of space efficiencies for individual capabilities.  
  [TieringPolicyEnum[]]$tieringPolicies #List of tiering policies for individual capabilities.  
  [ServiceLevelEnum[]]$serviceLevels #List of service levels for individual capabilities.  

  #Methods

}

<#
  Name: UnitycertificateScope
  Description: Scope of the certificate: <ul> <li>If the certificate scope is global, the attribute values are blank.</li> <li>If the certificate scope is local, the scope is defined by one attribute value (for queries) or one argument value (for create and import operations). For example, if the scope of the certificate is NAS server nas01, the value of the nasServer attribute would be nas01, and all other attributes would be blank.</li> </ul> <p> For information about which scopes apply to which services, see the help topic for the ServiceTypeEnum.  
#>
Class UnitycertificateScope {

  #Properties

  [Object]$nasServer #NAS Server with which the certificate is associated.  

  #Methods

}

<#
  Name: UnitycifsFilesystemParameters
  Description: Settings for a SMB (also known as CIFS) file system.. <br/> <br/> This resource type is embedded in the storageResource resource type.  
#>
Class UnitycifsFilesystemParameters {

  #Properties

  [Bool]$isCIFSSyncWritesEnabled #Indicates whether the CIFS synchronous writes option is enabled for the file system. Values are: <ul> <li>true - CIFS synchronous writes option is enabled.</li> <li>false - CIFS synchronous writes option is disabled.</li> </ul>  
  [Bool]$isCIFSOpLocksEnabled #Indicates whether opportunistic file locks are enabled for the file system. Values are: <ul> <li>true - CIFS opportunistic file locks are enabled.</li> <li>false - CIFS opportunistic file locks are disabled.</li> </ul>  
  [Bool]$isCIFSNotifyOnWriteEnabled #Indicates whether the system generates a notification when the file system is written to. Values are: <ul> <li>true - System generates a notification when the file system is written to.</li> <li>false - System does not generate a notification when the file system is written to.</li> </ul>  
  [Bool]$isCIFSNotifyOnAccessEnabled #Indicates whether the system generates a notification when a user accesses the file system. Values are: <ul> <li>true - System generates a notification when a user accesses the file system.</li> <li>false - System does not generate a notification when a user accesses the file system.</li> </ul>  
  [Object]$cifsNotifyOnChangeDirDepth #Indicates the lowest directory level to which the enabled notifications apply, if any.  

  #Methods

}

<#
  Name: UnitycifsShareACE
  Description: Access Control Entry (ACE) settings for CIFS shares. <br/> <br/> This resource type is embedded in the storageResource type.  
#>
Class UnitycifsShareACE {

  #Properties

  [String]$sid #Domain user or group Security Identifier (SID).  
  [ACEAccessTypeEnum]$accessType #ACE type. Set this value to <b>None</b> to remove the ACE for a SID from a CIFS share.  
  [ACEAccessLevelEnum]$accessLevel #ACE level.  

  #Methods

}

<#
  Name: UnitycifsShareCreate
  Description: (Applies to SMB (also known as CIFS) file shares.) Parameters used for creating a CIFS share when creating or modifying a file system. <br/> <br/> This resource type is embedded in the storageResource resource type.  
#>
Class UnitycifsShareCreate {

  #Properties

  [String]$path #Local path to a location within a file system. <br/> <br/> <font color=#0f0f0f>By default, the system creates a share to the root of the file system (top-most directory) at file system creation time. </font>This path specifies the unique location of the file system on the storage system. CIFS shares allow you to create multiple network shares with the same local path. You can specify different host-side access controls for different users, while setting up network shares within the file system to access common content. <br/> <br/> If you want the CIFS network shares within the same file system to access different content, you must first create a share to the root of the file system. Then, you can connect from a Windows host, create additional directories from Windows, and create corresponding network shares using the REST API, Unisphere GUI, or Unisphere CLI.  
  [String]$name #Name of the CIFS share unique to NAS server.  
  [Object]$cifsServer #CIFS server to use for CIFS share creation, as defined by the cifsServer type.  
  [Object]$cifsShareParameters #CIFS share settings, as defined by the cifsShareParameters type.  

  #Methods

}

<#
  Name: UnitycifsShareDelete
  Description: Parameters used for deleting a CIFS share when modifying a file system. <br/> <br/> This resource type is embedded in the storageResource resource type.  
#>
Class UnitycifsShareDelete {

  #Properties

  [Object]$cifsShare #CIFS share to delete, as defined by the cifsShare type.  

  #Methods

}

<#
  Name: UnitycifsShareModify
  Description: Parameters used for modifying a CIFS share when modifying a file system. <br/> <br/> This resource type is embedded in the storageResource resource type.  
#>
Class UnitycifsShareModify {

  #Properties

  [Object]$cifsShare #CIFS share to modify, as defined by the cifsShare type.  
  [Object]$cifsShareParameters #CIFS share settings, as defined by the cifsShareParameters type.  

  #Methods

}

<#
  Name: UnitycifsShareParameters
  Description: Settings for a CIFS share. <br/> <br/> This resource type is embedded in the storageResource resource type.  
#>
Class UnitycifsShareParameters {

  #Properties

  [String]$description #CIFS share description.  
  [Bool]$isReadOnly #Indicates whether the CIFS share is read-only. Values are: <ul> <li>true - CIFS share is read-only.</li> <li>false - CIFS share is read-write.</li> </ul>  
  [Bool]$isEncryptionEnabled #Indicates whether CIFS encryption for Server Message Block (SMB) 3.0 is enabled for the CIFS share. Values are: <ul> <li>true - CIFS encryption for SMB 3.0 is enabled. <li>false - CIFS encryption for SMB 3.0 is disabled. </ul>  
  [Bool]$isContinuousAvailabilityEnabled #Indicates whether continuous availability for SMB 3.0 is enabled for the CIFS share. Values are: <ul> <li>true - Continuous availability for SMB 3.0 is enabled for the CIFS share. <li>false - Continuous availability for SMB 3.0 is disabled for the CIFS share. </ul>  
  [Bool]$isACEEnabled #Indicates whether the CIFS share access-level permissions are enabled. Values are: <ul> <li>true - CIFS share access-level permissions are enabled. <li>false - CIFS share access-level permissions are disabled. </ul>  
  [Object[]]$addACE #Users, domain users, or group Security Identifiers (SIDs), and associated access-level permissions, to add to the access list, as defined by cifsShareACE resource type.  
  [String[]]$deleteACE #Users, domain users, or group Security Identifiers (SIDs) to remove from the access list.  
  [Bool]$isABEEnabled #Enumerate file with read access and directories with list access in folder listings. Values are: <ul> <li> true - Enumerating is enabled. </li> <li> false - Enumerating is disabled. </li> </ul>  
  [Bool]$isBranchCacheEnabled #Branch Cache optimizes traffic between the NAS server and Branch Office Servers. Values are: <ul> <li> true - Branch Cache is enabled. </li> <li> false - Branch Cache is disabled. </li> </ul>  
  [CifsShareOfflineAvailabilityEnum]$offlineAvailability #Offline Files store a version of the shared resources on the client computer in the file system cache, a reserved portion of disk space, which the client computer can access even when it is disconnected from the network.  
  [String]$umask #The default UNIX umask for new files created on the share.  

  #Methods

}

<#
  Name: UnitycompressionParameters
  Description: Inline compression settings for the storage resource. <br/> <br/> This resource type is embedded in the storageResource resource type.  
#>
Class UnitycompressionParameters {

  #Properties

  [Bool]$isCompressionEnabled #Indicates whether inline compression is enabled or disabled for the storage resource. Values are: <ul> <li>true - (default)inline compression is enabled.</li> <li>false - inline compression is disabled.</li> </ul>  
  [Object]$compressionSizeSaved #Storage resource saved space by inline compression  
  [Object]$compressionPercent #Percent compression rate  

  #Methods

}

<#
  Name: UnityconfigCaptureResult
  Description: Information about Configuration Capture results in the storage system. <br/> <br/> Configuration Capture is a service feature which creates a snapshot of the current system configuration. It captures all of the necessary data for business intelligence analysis, helping diagnose issues. <br/> <br/>  
#>
Class UnityconfigCaptureResult {

  #Properties

  [String]$id #Unique identifier of the configCaptureResult instance.  
  [String]$name #File name of the configCaptureResult instance.  
  [DateTime]$creationTime #Date and time when the configCaptureResult file was created.  

  #Methods

}

<#
  Name: Unitycrl
  Description: Information about all Certificate Revocation Lists (CRLs) installed on the storage system. The CRL format is described in RFC 5280.  
#>
Class Unitycrl {

  #Properties

  [String]$id #Unique identifier of the crl instance.  
  [ServiceTypeEnum]$service #Service with which the CRL is associated.  
  [Object]$scope #Scope of the CRL.  
  [Object]$version #CRL version.  
  [String]$crlNumber #CRL number. This is equivalent to a serial number for the CRL.  
  [SignatureAlgoTypeEnum]$signatureAlgorithm #CRL signature algorithm.  
  [String]$issuer #Name of the CRL issuer.  
  [DateTime]$thisUpdate #Date and time when the CRL was issued.  
  [DateTime]$nextUpdate #Date and time when the next CRL will be issued.  
  [Object[]]$certificates #List of revoked certificates.  
  [String]$deltaCRLIndicator #Delta CRL indicator. The value of this attribute is based on the delta CRL extension, which is a CRL number. This value can be blank.  

  #Methods

}

<#
  Name: Unitydae
  Description: Information about Disk Array Enclosure (DAE) components in the storage system.  
#>
Class Unitydae {

  #Properties

  [String]$id #Unique identifier of the dae instance.  
  [UnityHealth]$health #Health information for the DAE, as defined by the health resource type.  
  [Bool]$needsReplacement #Indicates whether the DAE needs replacement. Values are: <ul> <li>true - DAE needs replacement.</li> <li>false - DAE does not need replacement.</li> </ul>  
  [Object]$parent #Resource type and unique identifier of the DAE's parent enclosure.  
  [Object]$slotNumber #The enclosure number or position where the DAE is located on the bus.  
  [String]$name #DAE name.  
  [String]$manufacturer #Manufacturer of the DAE.  
  [String]$model #Manufacturer's model number for the DAE.  
  [String]$emcPartNumber #EMC part number for the DAE.  
  [String]$emcSerialNumber #EMC serial number for the DAE.  
  [String]$vendorPartNumber #Vendor part number for the DAE.  
  [String]$vendorSerialNumber #Vendor serial number for the DAE.  
  [EnclosureTypeEnum]$enclosureType #DAE enclosure type.  
  [Object]$busId #Identifier of the bus used by the DAE.  
  [DiskTypeEnum[]]$driveTypes #Disk type of the disks in the DAE.  
  [Object]$currentPower #Current amount of power used by the DAE.  
  [Object]$avgPower #Average amount of power used by the DAE. The system uses a one hour window of 30-second samples to determine this value.  
  [Object]$maxPower #Maximum amount of power used by the DAE. The system uses a one hour window of 30-second samples to determine this value.  
  [Object]$currentTemperature #Current temperature of the DAE.  
  [Object]$avgTemperature #Average temperature of the DAE. The system uses a one hour window of 30-second samples to determine this value.  
  [Object]$maxTemperature #Maximum temperature of the DAE. The system uses a one hour window of 30-second samples to determine this value.  
  [Object]$currentSpeed #Current speed of the DAE SAS disk connection.  
  [Object]$maxSpeed #Maximum speed of the DAE SAS disk connection. The system uses a one hour window of 30-second samples to determine this value.  
  [Object]$parentSystem #Parent system of the Disk Array Enclosure (DAE).  

  #Methods

}

<#
  Name: UnitydataCollectionResult
  Description: Information about Data Collection results in the storage system. <br/> <br/> Data Collection is a service feature used for gathering system logs, customer configurations, system statistics and runtime data from storage system. <br/> <br/>  
#>
Class UnitydataCollectionResult {

  #Properties

  [String]$id #Unique identifier of the dataCollectionResult instance.  
  [String]$name #File name of the dataCollectionResult instance.  
  [DateTime]$creationTime #Date and time when the dataCollectionResult file was created.  

  #Methods

}

<#
  Name: Unitydatastore
  Description: Represents a VMware Datastore.  
#>
Class Unitydatastore {

  #Properties

  [String]$id #Unique instance id.  
  [Object]$storageResource #storageResource that hosts the datastore.  
  [String]$name #Friendly name of datastore displayed on vCenter.  
  [DatastoreTypeEnum]$format #Format of datastore.  
  [Object]$host #The host that owns this datastore.  
  [Object]$sizeTotal #Size of the datastore in bytes reported by vCenter. Could be different from size of the associated storage resource.  
  [Object]$sizeUsed #Used size of the datastore (in bytes) as reported by vCenter. This may be different from the used size of the associated storage resource. For VMware VMFS datastores, this provides information about the actual hosted file system allocation size.  
  [Object[]]$vmDisks #The vmDisks associated with the current datastore
  [Object[]]$vms #The vms associated with the current datastore

  #Methods

}

<#
  Name: UnitydhsmConnection
  Description: When doing cloud archiving, the Cloud Tiering Applicance (a.k.a CTA) is responsible for moving the local data to cloud. On the other direction, when we need to bring the data back to local, DHSM server will read the data back via a pipe so called dhsm connection. This class represents this dhsm connection @author wangt23  
#>
Class UnitydhsmConnection {

  #Properties

  [String]$id #Unique instance id.  
  [DhsmConnectionModeEnum]$mode #Mode of the connection.  
  [RecallPolicyEnum]$readPolicy #The read policy when Unity recall data from secondary storage. <ul> <li>full-recalls the whole file to Unity on read request before the data is returned.</li> <li>passthrough-retrieves data without recalling the data to Unity</li> <li>partial-recalls only the blocks required to satisfy the client read request.</li> <li>none-specifies no override</li> </ul>  
  [String]$secondaryUrl #Url of the secondary storage. If secondary storage is NFS or CIFS, this URL should point to them directly. If the secondary is cloud or Centera, this Url should point to CTA.  
  [Object]$secondaryPort #Port of the secondary storage server, only applicable when secondary url points to CTA.  
  [Object]$localPort #Local port of the DHSM connections  
  [String]$secondaryUsername #Defines the username the storage array uses if HTTP digest authentication is required by the secondary storage.  
  [Object]$timeout #Connection timeout when the connection is established to the secondary storage. If recall does not return within the timeout, the NAS server will try another DhsmConnection.  
  [Object]$filesystem #File system on which the connection is created.  

  #Methods

}

<#
  Name: UnitydhsmServer
  Description: Information about the ASA/DHSM server of a NAS server. You can configure one ASA/DHSM server per NAS server. <br/> <br/> ASA stands for Advanced Storage Access. ASA allows VMware administrators to manage appropriately configured host configurations by taking advantage of advanced file operations that optimize NFS storage utilization. Once ASA is enabled on the NAS server, EMC's VSI Unified Storage Management tool can be utilized for the following: <ul> <li>Simplifying the process of creating NFS datastores,</li> <li>Compressing virtual machines in NFS datastores,</li> <li>Reducing the amount of storage consumed by virtual machines by using compression and Fast Clone technologies. The cloning functions include fast clones (thin copy/snaps) of Virtual Machine Disk (VMDF) files and full clones (full copy) of Virtual Machine Disk (VMDF) files.</li> </ul>  
#>
Class UnitydhsmServer {

  #Properties

  [String]$id #Unique identifier of the dhsmServer instance  
  [Object]$nasServer #NAS server that is configured with these DHSM settings.  
  [String]$username #User name for authentication to the DHSM/ASA server.  
  [Bool]$isHTTPSEnabled #Require SSL (HTTPS) for DHSM requests to this DHSM server.  

  #Methods

}

<#
  Name: UnitydiskParameters
  Description: Disk settings (disk ID and tier) to add a disk to a storage pool.  
#>
Class UnitydiskParameters {

  #Properties

  [Object]$disk #Disk identifier.  
  [Object]$tier #Storage tier to which the disk should be assigned.  

  #Methods

}

<#
  Name: Unitydpe
  Description: Information about Disk Processor Enclosures (DPEs) in the storage system.  
#>
Class Unitydpe {

  #Properties

  [String]$id #Unique identifier of the dpe instance.  
  [UnityHealth]$health #Health information for the DPE, as defined by the health resource type.  
  [Bool]$needsReplacement #Indicates whether the DPE needs replacement. Values are: <ul> <li>true - DPE needs replacement.</li> <li>false - DPE does not need replacement.</li> </ul>  
  [Object]$parent #Resource type and unique identifier of the DPE's parent enclosure.  
  [Object]$slotNumber #The enclosure number or position where the DPE is located on the bus.  
  [String]$name #DPE name.  
  [String]$manufacturer #Manufacturer of the DPE.  
  [String]$model #Manufacturer's model number for the DPE.  
  [String]$emcPartNumber #EMC part number for the DPE.  
  [String]$emcSerialNumber #EMC serial number for the DPE.  
  [String]$vendorPartNumber #Vendor part number for the DPE.  
  [String]$vendorSerialNumber #Vendor serial number for the DPE.  
  [EnclosureTypeEnum]$enclosureType #DPE enclosure type.  
  [Object]$busId #Identifier of the SAS bus used by the DPE.  
  [DiskTypeEnum[]]$driveTypes #Disk type of the disks in the DPE.  
  [Object]$currentPower #Current amount of power used by the DPE.  
  [Object]$avgPower #Average amount of power used by the DPE. The system uses a one hour window of 30-second samples to determine this value.  
  [Object]$maxPower #Maximum amout of power used by the DPE. The system uses a one hour window of 30-second samples to determine this value.  
  [Object]$currentTemperature #Current temperature of the DPE.  
  [Object]$avgTemperature #Average temperature of the DPE. The system uses a one hour window of 30-second samples to determine this value.  
  [Object]$maxTemperature #Maximum temperature of the DPE. The system uses a one hour window of 30-second samples to determine this value.  
  [Object]$currentSpeed #Current speed of the DPE SAS disk connection.  
  [Object]$maxSpeed #Maximum speed of the DPE SAS disk connection. The system uses a one hour window of 30-second samples to determine this value.  
  [Object]$parentSystem #Parent system of the Disk Processor Enclosure (DPE).  

  #Methods

}

<#
  Name: UnityelementImport
  Description: Member element import details in an import session.  
#>
Class UnityelementImport {

  #Properties

  [Object]$srcElement #Source element of the element import  
  [Object]$targetElement #Target element of the element import  
  [UnityHealth]$health #Health information for the import element, as defined by the health resource type.  
  [Object]$syncProgress #Import sync progress details.  
  [ImportStateEnum]$state #State of element import.  
  [Object]$targetImportIf #Target replication interface for nas import data transfer between source system and target system.  

  #Methods

}

<#
  Name: Unityencryption
  Description: Information about the data encryption of the storage system. <br/> <br/>  
#>
Class Unityencryption {

  #Properties

  [String]$id #Unique identifier of the encryption instance.  
  [EncryptionModeEnum]$encryptionMode #Encryption mode of the array. At present only Controller Based Encryption (CBE) mode is supported.  
  [EncryptionStatusEnum]$encryptionStatus #Encryption status.  
  [Float]$encryptionPercentage #Percentage of storage (in-place data) encrypted on the array. The percentage value will range from 0.00 to 100. Once the encryption is activated on the array, encryption percentage will not dip as the new data is written because the new data will be encrypted on the fly.  
  [KeyManagerBackupKeysStatusEnum]$keyManagerBackupKeyStatus #Key store back up status.  

  #Methods

}

<#
  Name: UnityesrsParam
  Description: Information about the EMC Remote Support (ESRS) configuration<br/> <br/> Unity Remote Support is enabled with the EMC&#8217;s leading remote support platform: EMC Secure Remote Support (ESRS). ESRS is a remote monitoring and support feature that provides authorized personnel with EMC remote access capabilities to storage systems via a secure and encrypted tunnel. The secure tunnel that ESRS establishes between the storage system and systems on the EMC network can be used to transfer files out to the storage system or back to EMC.<br/> <br/> ESRS provides the following features in providing an end-to-end remote support solution:<br/> <br/> <ul> <li>Automation - IP based connection enables fast remote diagnosis and repair of potential problems before an impact to business operations is noticed.</li> <li>Authentication - Advanced security features such as AES 256-bit encryption and RSA digital certificates ensure data privacy.</li> <li>Authorization - Customizable policies that you control include the ability to allow or deny remote support sessions.</li> <li>Audit - Detailed audit capabilities enable compliance with regulatory and internal business requirements.</li> </ul> <br/> ESRS offers two remote support solutions:<br/> <ul> <li>Integrated solution, which uses ESRS Virtual Edition (ESRS V3) technology integrated into the storage system to connect with EMC</li> <li>Centralized solution, which uses the ESRS Virtual Edition (ESRS V3) to connect with EMC</li> </ul> <br/> Setting up Remote Support requires: <br/> <ul> <li>An installed EMC Support license</li> <li>Valid support credentials</li> <li>A configured DNS server</li> </ul> <br/> For information about ESRS components and setup, go to the support website.<br/> Note that all proxy configuration for integrated support is now available from the supportProxy object. These properties proxyIsEnabled,proxyStatus,proxyAddress,proxyIsHTTP,proxyUserName are deprecated and will be removed in a future release. <br/> <br/> <b>Examples</b> <br/> <br/> <html> <head> <style> div.examplebox { background-color: #eff5fa; width: 600px; padding: 5px; border: 2px solid black; } </style> </head> <body> <br/> <b>Series operations need to perform to enable Integrated Remote Support</b><br/> <br/> Step 1: Accept EULA. The EULA must be accepted before any other configurations. <div class="examplebox"> <p> POST /api/instances/esrsParam/0/action/modify <br/> { <br/> &nbsp;&nbsp;&nbsp;&nbsp;&quot;isEsrsVeEulaAccepted&quot; : &quot;true&quot;<br/> }<br/> </p> </div> <br/> <br/> Step 2: Update contact infomation in systemInformation object. EMC will use this information to contact end user when errors detected. <div class="examplebox"> <p> POST /api/instances/systemInformation/0/action/modify <br/> { <br/> &nbsp;&nbsp;&nbsp;&nbsp;&quot;contactFirstName&quot; : &quot;Jill&quot;,<br/> &nbsp;&nbsp;&nbsp;&nbsp;&quot;contactLastName&quot; : &quot;Valentine&quot;,<br/> &nbsp;&nbsp;&nbsp;&nbsp;&quot;contactCompany&quot; : &quot;Umbrella Corporation&quot;,<br/> &nbsp;&nbsp;&nbsp;&nbsp;&quot;contactEmail&quot; : &quot;jill.valentine@umbrella.com&quot;,<br/> &nbsp;&nbsp;&nbsp;&nbsp;&quot;contactPhone&quot; : &quot;111-111-1111&quot;<br/> }<br/> </p> </div> <br/> <br/> Step 3: Set proxy server if the user wants to configure Integrated Remote Support with a proxy server. This step can be skipped if user doesn't want to use proxy server. <div class="examplebox"> <p> POST /api/instances/supportProxy/0/action/modify <br/> { <br/> &nbsp;&nbsp;&nbsp;&nbsp;&quot;isEnabled&quot; : &quot;true&quot;,<br/> &nbsp;&nbsp;&nbsp;&nbsp;&quot;address&quot; : &quot;10.105.221.123:1080&quot;,<br/> &nbsp;&nbsp;&nbsp;&nbsp;&quot;protocol&quot; : &quot;1&quot;,<br/> &nbsp;&nbsp;&nbsp;&nbsp;&quot;username&quot; : &quot;darthv&quot;,<br/> &nbsp;&nbsp;&nbsp;&nbsp;&quot;password&quot; : &quot;password&quot;<br/> }<br/> </p> </div> <br/> <br/> Step 4: Validate Network connectivity between Integrated Remote Support client and EMC servers. <div class="examplebox"> <p> POST /api/instances/esrsParam/0/action/checkNetwork <br/> { <br/> }<br/> </p> </div> <br/> <br/> Following steps are try to get the available sites for the current system, select the correct one and set it into Integrated Remote Support client.<br/> Step 5: Request for an access code. This access code will be used later to get the available sites. <div class="examplebox"> <p> POST /api/instances/esrsParam/0/action/requestAccessCode <br/> { <br/> }<br/> </p> </div> <br/> <br/> Step 6: Get the available sites with the access code. <div class="examplebox"> <p> POST /api/instances/esrsParam/0/action/getAvailableSites <br/> { <br/> &nbsp;&nbsp;&nbsp;&nbsp;&quot;accessCode&quot; : &quot;243857&quot;<br/> }<br/> </p> </div> <br/> <br/> Step 7: Set siteId. Select the correct site id from the returned sites in previous request. <div class="examplebox"> <p> POST /api/instances/esrsParam/0/action/modify <br/> { <br/> &nbsp;&nbsp;&nbsp;&nbsp;&quot;siteId&quot; : &quot;324546&quot;<br/> }<br/> </p> </div> <br/> <br/> Now, Integration Remote Support is enabled. <br/> <br/> <b>Disabling Integrated Remote Support</b><br/> <br/> If a proxy server or Policy Manager are enabled, they will automatically be disabled.<br/> <br/> <div class="examplebox"> <p> POST /api/instances/esrsParam/0/action/modify <br/> { <br/> &nbsp;&nbsp;&nbsp;&nbsp;&quot;enabled&quot; : &quot;false&quot;,<br/> &nbsp;&nbsp;&nbsp;&nbsp;&quot;isCentralized&quot; : &quot;false&quot;<br/> }<br/> </p> </div> <br/> <br/> <b>Checking the Integrated Remote Support status</b><br/> <br/> <div class="examplebox"> <p> GET /api/types/esrsParam/instances?fields=enabled,isCentralized <br/> <br/> &nbsp;&nbsp;&nbsp;&nbsp;&quot;content&quot;:<br/> &nbsp;&nbsp;&nbsp;&nbsp;{<br/> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&quot;isCentralized&quot; : &quot;false&quot;,<br/> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&quot;status&quot; : 2<br/> &nbsp;&nbsp;&nbsp;&nbsp;}<br/> <br/> </p> </div> <br/> <br/> <b>Checking the Integrated Remote Support configuration</b><br/> <br/> <div class="examplebox"> <p> GET /api/types/esrsParam/instances?fields=enabled,isCentralized,status, statusDescription::@enum(status)<br/> <br/> Sample response:<br/> <br/> &quot;content&quot;:<br/> { <br/> &nbsp;&nbsp;&nbsp;&nbsp;&quot;enabled&quot; : &quot;true&quot;,<br/> &nbsp;&nbsp;&nbsp;&nbsp;&quot;isCentralized&quot; : &quot;false&quot;,<br/> &nbsp;&nbsp;&nbsp;&nbsp;&quot;status&quot; : &quot;2&quot;<br/> &nbsp;&nbsp;&nbsp;&nbsp;&quot;statusDescription&quot; : &quot;connected&quot;<br/> }<br/> <br/> The statusDescription attribute is a calculated attribute that translates the normalized status value into a user friendly string.<br/> </p> </div> <br/> <br/> <b>Enabling Centralized Remote Support</b><br/> <br/> <div class="examplebox"> <p> POST /api/instances/esrsParam/0/action/modify <br/> { <br/> &nbsp;&nbsp;&nbsp;&nbsp;&quot;enabled&quot; : &quot;true&quot;,<br/> &nbsp;&nbsp;&nbsp;&nbsp;&quot;isCentralized&quot; : &quot;true&quot;,<br/> &nbsp;&nbsp;&nbsp;&nbsp;&quot;esrsVeAddress&quot; : &quot;10.105.221.123&quot;<br/> }<br/> </p> </div> <br/> <br/> <b>Modifying the Centralized Remote Support appliance</b><br/> <br> This example disconnects the storage system from the current ESRS VE appliance and reconnects it to a new one.<br/> <br/> <div class="examplebox"> <p> POST /api/instances/esrsParam/0/action/modify <br/> { <br/> &nbsp;&nbsp;&nbsp;&nbsp;&quot;enabled&quot; : &quot;true&quot;,<br/> &nbsp;&nbsp;&nbsp;&nbsp;&quot;isCentralized&quot; : &quot;true&quot;,<br/> &nbsp;&nbsp;&nbsp;&nbsp;&quot;esrsVeAddress&quot; : &quot;myveserver.acme.com:2135&quot;<br/> }<br/> </p> </div> <br/> <br/> <b>Disabling Centralized Remote Support</b><br/> <br/> <div class="examplebox"> <p> POST /api/instances/esrsParam/0/action/modify <br/> { <br/> &nbsp;&nbsp;&nbsp;&nbsp;&quot;enabled&quot; : &quot;false&quot;<br/> &nbsp;&nbsp;&nbsp;&nbsp;&quot;isCentralized&quot; : &quot;true&quot;,<br/> }<br/> </p> </div> </body> </html> <br/> <br/> * <br/> <br/> <b>Switching between Integrated and Centralized Remote Support</b><br/> <br/> This example assumes that Integrated Remote Support is enabled. It will be disabled before the Centralized Remote Support is enabled.<br/> <br/> <div class="examplebox"> <p> POST /api/instances/esrsParam/0/action/modify <br/> { <br/> &nbsp;&nbsp;&nbsp;&nbsp;&quot;enabled&quot; : &quot;true&quot;,<br/> &nbsp;&nbsp;&nbsp;&nbsp;&quot;isCentralized&quot; : &quot;true&quot;,<br/> &nbsp;&nbsp;&nbsp;&nbsp;&quot;esrsVeAddress&quot; : &quot;10.105.221.123&quot;<br/> }<br/> </p> </div>  
#>
Class UnityesrsParam {

  #Properties

  [String]$id #Unique identifier of the Remote Support instance.<br/> <br/> --eng This value is always 0, because at any given time there can only one remote support solution enabled.  
  [Bool]$enabled #Indicates whether Remote Support is enabled<br/> <br/> Values are:<br/> <ul> <li>true - Remote Support is enabled.</li> <li>false - Remote Support is disabled.</li> </ul> <br/> See <i>isCentralized</i> to view the type of Remote Support.  
  [Bool]$isCentralized #Indicates the type of Remote Support that is configured<br/> <br/> Values are:<br/> <ul> <li>true - Centralized Remote Support is configured</li> <li>false - Integrated Remote Support is configured</li> </ul> <br/> This attribute is not valid if <i>enabled</i> is <i>false</i>.  
  [EsrsStatusEnum]$status #Remote Support status  
  [Object]$esrsVeAddress #Centralized Remote Support ESRS VE appliance.  

  #Methods

}

<#
  Name: UnityesxDatastore
  Description: Information about the ESX datastores used for configuring the metrics service.  
#>
Class UnityesxDatastore {

  #Properties


  #Methods

}

<#
  Name: Unityevent
  Description: Information about the events reported by the storage system. <br/> <br/> The system monitors and reports on a variety of system events. It collects the events and writes them to the user log, which contains a record for each event. <br/> <br/> The health and alert providers promote some events to be alerts, which are usually events that require attention from the system administrator. For information about alerts, see the Help topic for the alert resource type. <br/> <br/> <b>In the username attribute, is the value N/A or blank if a user did not cause the event or the account is unavailable?</b>  
#>
Class Unityevent {

  #Properties

  [String]$id #Unique identifier of the event instance.  
  [NodeEnum]$node #Storage Processor that generated the event.  
  [DateTime]$creationTime #<ol> <li>Date and time when the event was created.</li> </ol>  
  [SeverityEnum]$severity #Severity of the event.  
  [String]$messageId #Identifier of the message, without arguments or localization.  
  [String[]]$arguments #Arguments in the event message.  
  [String]$message #Localized description of the event's cause or effects.  
  [String]$username #If a user caused the event, and the user account still exists, the user associated with the event.  
  [EventCategoryEnum]$category #Event category.  
  [String]$source #System component that caused the event. This information is intended for service personnel.  

  #Methods

}

<#
  Name: UnityfastVP
  Description: System FAST VP settings. FAST VP allows performing automatic data relocation between tiers and rebalancing within a tier to improve storage performance. Currently there three types of relocations supported: <br/> <li>Scheduled relocations</li> <li>Manual relocations</li> <li>Rebalancing</li> <br/> Scheduled relocations are started according the schedule defined in this resource. Individual pools can be included to or excluded from the scheduled relocation process. <br/> Manual relocations can be performed on demand for each particular pool. <br/> Rebalancing is performed automatically on a pool extend event. <br/> The FAST VP object represents the status of scheduled relocation processes and allows to view or modify the scheduled relocation parameters. It also provides a means to pause or resume all the FAST VP relocation and rebalancing processes currently running on the system.  
#>
Class UnityfastVP {

  #Properties

  [String]$id #Unique instance id.  
  [FastVPStatusEnum]$status #FAST VP status. The possible values are "Active" or "Paused".  
  [FastVPRelocationRateEnum]$relocationRate #Relocation Rate to perform scheduled relocations.  
  [Bool]$isScheduleEnabled #Indicates whether FAST VP scheduled relocations are enabled.  
  [DayOfWeekEnum[]]$scheduleDays #Days of week to run scheduled relocations.  
  [DateTime]$scheduleStartTime #Time of day to start scheduled relocation.  
  [DateTime]$scheduleEndTime #Time of day at which scheduled relocation should end.  
  [Object]$sizeMovingDown #Current estimate of the amount of data that the next scheduled relocation will move to a lower tier.  
  [Object]$sizeMovingUp #Current estimate of the amount of data that the next scheduled relocation will move to a higher tier.  
  [Object]$sizeMovingWithin #Current estimate of the amount of data that the next scheduled relocation will rebalance within a tier.  
  [DateTime]$relocationDurationEstimate #Based on current amounts of data to move, this is the current estimate of how long a scheduled relocation would take.  

  #Methods

}

<#
  Name: UnityfastVPParameters
  Description: FAST VP settings for the storage resource. <br/> (Applies if FAST VP is supported on the system and the corresponding license is installed.) <br/> This resource type is embedded in the storageResource resource type.  
#>
Class UnityfastVPParameters {

  #Properties

  [TieringPolicyEnum]$tieringPolicy #FAST VP tiering policy for the storage resource.  

  #Methods

}

<#
  Name: UnityfileDNSServerSourceParameters
  Description: For replication destination NAS servers, information about the corresponding source NAS server's DNS settings. <br/>  
#>
Class UnityfileDNSServerSourceParameters {

  #Properties

  [Object[]]$addresses #List of IP addresses of DNS servers of the source NAS server  

  #Methods

}

<#
  Name: UnityfileEventSettings
  Description: File Event Service supported protocols.  
#>
Class UnityfileEventSettings {

  #Properties

  [Bool]$isCIFSEnabled #Indicates whether file access over CIFS protocol will trigger sending events to the CEPA server.  
  [Bool]$isNFSEnabled #Indicates whether file access over NFSv3 or NFSv4 protocols will trigger sending events to the CEPA server.  

  #Methods

}

<#
  Name: UnityfileEventsPool
  Description: File Event Service pool is a pool of remote File Event Service servers (machines that run VEE and are capable to handle event notificatons from the NAS Server). NAS Server can have one or several (up to three) File Event Service pools. The File Event Service pool servers are responsible for: - maintaining a topology and state mapping of all consumer applications - delivering event type and associated event metadata through the publishing agent API <br/> <br/>  
#>
Class UnityfileEventsPool {

  #Properties

  [String]$id #Unique identifier of the File Event Service Pool instance.  
  [Object]$eventsPublisher #Associated File Event Service identifier.  
  [String]$name #Name assigned to the set of Windows servers where File Event Service software is installed.  
  [Object[]]$servers #Addresses of the File Event Service servers.  
  [Object[]]$sourceServers #For replication destination NAS servers, the list of File Event Service servers from the corresponding source NAS server.  
  [FileEventTypesEnum[]]$preEvents #The list of pre-events. The NAS server sends request event notification to CEPA server before such event occurs and processes the response.  
  [FileEventTypesEnum[]]$postEvents #The list of post-evenets. The NAS server sends notification after such event occrus.  
  [FileEventTypesEnum[]]$postErrorEvents #The list of post-error events. The NAS server sends notification if such event generates an error.  
  [ReplicationPolicyEnum]$replicationPolicy #Replication policy of the Events Pool.  

  #Methods

}

<#
  Name: UnityfileEventsPublisher
  Description: File Event Service is a mechanism whereby applications can register to receive event notification and context from sources such as VNX(e). File Event Service is a part of VNX Event Enabler Framework (VEE). VEE provides the working environment for the CAVA and CEPA (Common Event Publishing Agent) facilities. The event publishing agent delivers to the application both event notification and associated context in one message. Context may consist of file metadata or directory metadata needed to decide business policy. The CEPA sub-facilities include: - Auditing.A mechanism for delivering post-events to registered consumer applications in a synchronous manner. Events are delivered individually in real-time. - CQM.A mechanism for delivering pre-events to registered consumer applications in a synchronous manner. Events are delivered individually in real-time, allowing the consumer application to exercise business policy on the event. - VCAPS.A mechanism for delivering post-events in asynchronous mode. The delivery cadence is based on a time period or a number of events. - MessageExchange.A mechanism for delivering post-events in asynchronous mode, when needed, without consumer use of the CEPA API. Events are published from CEPA to the RabbitMQ CEE_Events exchange. A consumer application creates a queue for itself in the exchange from which it can retrieve events. <br/> <br/>  
#>
Class UnityfileEventsPublisher {

  #Properties

  [String]$id #Unique identifier of the File Event Service instance.  
  [Object]$nasServer #Associated NAS server identifier.  
  [Bool]$isEnabled #State of File Event Servce is currently enabled.  
  [UnityHealth]$health #Health information for the File Event Service, as defined by the health resource type.  
  [DateTime]$heartbeat #Time interval to scan each CEPA server (in seconds) for online/offline status.  
  [DateTime]$timeout #Timeout in ms while attempting to send event to a CEPA server to determine that is offline.  
  [FileEventsPublisherFTLevelTypeEnum]$postEventPolicy #The fault tolerance policy for handling post-events.  
  [Bool]$denyAccessWhenAllServersOffline #Behaviour when the File Event Service server did not answer. Values are: <ul> <li> false - indicates that nothing changes with I/O in case of File Event Service server is offline. </li> <li> true - indicates that all I/O is denied in case of File Event Service server is offline. </li> </ul>  
  [String]$username #Name of a Windows user allowing Events Publishing to connect to CEPA servers. To ensure that a secure connection (via Microsoft RPC protocol) is used disable HTTP by setting isHttpEnabled to false.  
  [Bool]$isHttpEnabled #Indicates whether connection to CEPA servers via HTTP is enabled. Default is true (enabled). When enabled, connection via HTTP is attempted first. If HTTP connection is disabled, or the connection fails, then connection through MSRPC is attempted if all CEPP server(s) are defined by FQDN. The SMB account of the NAS server in the AD comain is used to make the connection via MSRPC. Note that HTTP connections should only be used on secure networks, as it is neither SSL nor authenticated.  
  [Object]$port #When HTTP is used to connect to the CEPA server(s), the port number to use. Default port number is 12228.  

  #Methods

}

<#
  Name: UnityfileInterfaceSourceParameters
  Description: For an interface on a nasServers that is a replication destinations, this object contains the settings for corresponding interface on the source nasServer.  
#>
Class UnityfileInterfaceSourceParameters {

  #Properties

  [Object]$ipAddress #IP address of the network interface of the source NAS server  
  [Object]$netmask #IPv4 netmask for the network interface of the source NAS server.  
  [Object]$v6PrefixLength #IPv6 prefix length for the network interface of the source NAS server.  
  [Object]$gateway #IPv4 or IPv6 gateway address for the network interface of the source NAS server.  
  [Object]$vlanId #Virtual Local Area Network (VLAN) identifier for the network interface of the source NAS server.  
  [Object]$ipPort #Physical port or link aggregation of the network interface of the source NAS server.  

  #Methods

}

<#
  Name: UnityfileKerberosServer
  Description: Information about the Kerberos service used by the storage system for secure connections. You can configure one Kerberos settings object per NAS server. <br/> Kerberos is a distributed authentication service designed to provide strong authentication with secret-key cryptography. It works on the basis of "tickets" that allow nodes communicating over a non-secure network to prove their identity in a secure manner. When configured to act as a secure NFS server, the NAS server uses the RPCSEC_GSS security framework and Kerberos authentication protocol to verify users and services. You can configure a secure NFS environment for a multiprotocol NAS server or one that supports Unix-only shares. In this environment, user access to NFS file systems is granted based on Kerberos principal names. <br/>  
#>
Class UnityfileKerberosServer {

  #Properties

  [String]$id #Unique identifier of the Kerberos instance.  
  [Object]$nasServer #NAS server that is configured with these Kerberos settings.  
  [String]$realm #Kerberos Realm.  
  [String[]]$addresses #Fully Qualified domain names of the Kerberos Key Distribution Center (KDC) servers.  
  [Object]$portNumber #KDC servers TCP port. Default: 88.  

  #Methods

}

<#
  Name: UnityfileLDAPServer
  Description: The LDAP settings object for the NAS Server. You can configure one LDAP settings object per NAS server. <br/> The Lightweight Directory Access Protocol (LDAP) is an application protocol for querying and modifying directory services running on TCP/IP networks. LDAP provides central management for network authentication and authorization operations by helping to centralize user and group management across the network. NAS server can use LDAP as a Unix Directory Service to map users, retrieve netgroups, and build a Unix credential. When an initial LDAP configuration is applied, the system checks for the type of LDAP server. It can be an Active Directory schema, iPlanet schema, or an RFC 2307 schema.  
#>
Class UnityfileLDAPServer {

  #Properties

  [String]$id #Unique identifier of the ldapServer instance.  
  [Object]$nasServer #NAS server that is configured with these LDAP settings.  
  [String]$authority #Name of the LDAP authority. Base Distinguished Name (BDN) of the root of the LDAP directory tree. The system uses the DN to bind to the LDAP service and locate in the LDAP directory tree to begin a search for information. <br/> <br/> The base DN can be expressed as a fully-qualified domain name or in X.509 format by using the attribute dc=. For example, if the fully-qualified domain name is mycompany.com, the base DN is expressed as dc=mycompany,dc=com.  
  [String]$profileDN #For an iPlanet LDAP server, specifies the DN of the entry with the configuration profile.  
  [Object[]]$serverAddresses #IP addresses of the associated LDAP servers.  
  [Object]$portNumber #The TCP/IP port used by the NAS server to connect to the LDAP servers. Default value for LDAP is 389 and LDAPS is 636.  
  [AuthenticationTypeEnum]$authenticationType #Type of authentication for the LDAP server.  
  [LDAPProtocolEnum]$protocol #Type of LDAP protocol.  
  [Bool]$verifyServerCertificate #Indicates whether Certification Authority certificate is used to verify the LDAP server certificate for secure SSL connections. Values are: <ul> <li> true - verifies LDAP server's certificate. </li> <li> false - doesn't verify LDAP server's certificate. </li> </ul>  
  [String]$bindDN #Bind Distinguished Name (DN) to be used when binding.  
  [Bool]$isCifsAccountUsed #Indicates whether CIFS authentication is used to authenticate to the LDAP server. Values are: <ul> <li> true - Indicates that the CIFS settings are used for Kerberos authentication. </li> <li> false - Indicates that Kerberos uses its own settings. </li> </ul>  
  [String]$principal #Specifies the principal name for Kerberos authentication.  
  [String]$realm #Specifies the realm name for Kerberos authentication.  
  [SchemeTypeEnum]$schemeType #LDAP server scheme type.  
  [ReplicationPolicyEnum]$replicationPolicy #Indicates the status of the LDAP servers addresses list in the NAS server operating as a replication destination. When a replicated LDAP servers list is created on the source NAS server, it is automatically synchronized to the destination.  
  [Object]$sourceParameters #For replication destination NAS servers, information about the corresponding source NAS server's LDAP settings.  

  #Methods

}

<#
  Name: UnityfileLDAPServerSourceParameters
  Description: For replication destination NAS servers, information about the corresponding source NAS server's LDAP settings. <br/>  
#>
Class UnityfileLDAPServerSourceParameters {

  #Properties

  [Object[]]$addresses #List of IP addresses of LDAP servers of the source NAS server  

  #Methods

}

<#
  Name: UnityfileNDMPServer
  Description: The NDMP server for the NAS Server. You can configure one NDMP server per NAS server. <br/> The Network Data Management Protocol (NDMP) provides a standard for backing up file servers on a network. NDMP allows centralized applications to back up file servers that run on various platforms and platform versions. NDMP reduces network congestion by isolating control path traffic from data path traffic, which permits centrally managed and monitored local backup operations. Storage systems support NDMP v2-v4 over the network. Direct-attach NDMP is not supported. This means that the tape drives need to be connected to a media server, and the NAS server communicates with the media server over the network. NDMP has an advantage when using multiprotocol file systems because it backs up the Windows ACLs as well as the UNIX security information.  
#>
Class UnityfileNDMPServer {

  #Properties

  [String]$id #Unique instance id.  
  [Object]$nasServer #NAS server that is configured with these NDMP settings.  
  [String]$username #User name for accessing the NDMP server.  

  #Methods

}

<#
  Name: UnityfileNISServer
  Description: The NIS settings object for the NAS Server. You can configure one NIS settings object per NAS server. <br/> The Network Information Service (NIS) consists of a directory service protocol for maintaining and distributing system configuration information, such as user and group information, hostnames etc.  
#>
Class UnityfileNISServer {

  #Properties

  [String]$id #Unique identifier of the nisServer instance.  
  [Object]$nasServer #NAS server that is configured with these NIS settings.  
  [Object[]]$addresses #Prioritized list of one to ten NIS server IP addresses for the domain.  
  [String]$domain #Name of the NIS server domain.  
  [ReplicationPolicyEnum]$replicationPolicy #Indicates the status of the NIS servers addresses list in the NAS server operating as a replication destination. When a replicated NIS servers list is created on the source NAS server, it is automatically synchronized to the destination.  
  [Object]$sourceParameters #For replication destination NAS servers, information about the corresponding source NAS server's NIS settings.  

  #Methods

}

<#
  Name: UnityfileNISServerSourceParameters
  Description: For replication destination NAS servers, information about the corresponding source NAS server's NIS settings. <br/>  
#>
Class UnityfileNISServerSourceParameters {

  #Properties

  [Object[]]$addresses #List of IP addresses of NIS servers of the source NAS server  

  #Methods

}

<#
  Name: UnityfilesystemImportParameters
  Description: Settings to import a file system.  
#>
Class UnityfilesystemImportParameters {

  #Properties

  [String]$sourceFilesystemId #Source file system id.  
  [Object]$targetPool #Target pool.  
  [Bool]$importAsVMwareDatastore #Indicates whether to import this file system as VMware datastore. Values are: <ul> <li>true - Import this file system as VMware datastore, which results in vmwarefs storage resource type.</li> <li>false - Do not import this file system as VMware datastore, which results in filesystem storage resource type.</li> </ul>  

  #Methods

}

<#
  Name: UnityfilesystemParameters
  Description: Settings for a file system. <br/> <br/> This resource type is embedded in the storageResource resource type.  
#>
Class UnityfilesystemParameters {

  #Properties

  [Object]$nasServer #NAS server that provides network connectivity to the share from the hosts. The NAS server parameter is required in creation request and must not be passed in modification requests.  
  [FSSupportedProtocolEnum]$supportedProtocols #(Applies to create operations only.) Sharing protocols supported by the file system.  
  [Object]$pool #Storage pool to create the file system. The pool is required in creation requests and must not be passed in modification requests.  
  [Bool]$isFLREnabled #(Applies to create operations only.) Indicates whether File Level Retention (FLR) is enabled for the file system. Values are: <ul> <li>true - FLR is enabled for the file system.</li> <li>false - FLR is disabled for the file system.</li> </ul>  
  [Bool]$isThinEnabled #(Applies to create operations only.) Indicates whether to enable thin provisioning for file system. Values are: <ul> <li>true - Enable thin provisioning.</li> <li>false - Disable thin provisioning.</li> </ul> <b>Note:</b> If you enable thin provisioning for a file system, you cannot disable it later.  
  [Object]$size #Size of the file system.  
  [HostIOSizeEnum]$hostIOSize #Typical write I/O size from the host to the file system.  
  [Object]$sizeAllocated #Allocated size of the file system.  
  [Object]$minSizeAllocated #Minimum size allocated of the file system.  
  [Object]$fastVPParameters #(Applies if FAST VP is supported on the system and the corresponding license is installed.) FAST VP settings for the file system, as defined by the fastVPParameters.  
  [Bool]$isCacheDisabled #Indicates whether caching is disabled. Values are: <ul> <li>true - Caching is disabled.</li> <li>false - Caching is enabled.</li> </ul>  
  [Object]$deduplication #Deduplication settings for the file system, as defined by the deduplicationParameters resource type.  
  [AccessPolicyEnum]$accessPolicy #Access policy.  
  [FSRenamePolicyEnum]$folderRenamePolicy #File system folder rename policies. These policy choices control whether directory can be renamed from NFS or SMB clients if at least one file is opened in the directory or in one of its children directory.  
  [FSLockingPolicyEnum]$lockingPolicy #Locking policy.  
  [ResourcePoolFullPolicyEnum]$poolFullPolicy #Behavior to follow when pool is full and a write to this filesystem is attempted. Values are: <ul> <li>Delete_All_Snaps - All snaps to the File System will be marked for deletion to free up space.</li> <li>Fail_Writes - Writes to the File System will fail.</li> </ul>  
  [Object]$fileEventSettings #Indicates whether File Event Service is enabled for some protocols on the filesystem.  

  #Methods

}

<#
  Name: UnityfloatOrValueMap
  Description: A single floating point value that corresponds to the element in the metric or another mapping of a string to floatOrValueMap. This mapping allows for a hierarchical structure of values mapped to the metrics in the metric object.  
#>
Class UnityfloatOrValueMap {

  #Properties


  #Methods

}

<#
  Name: UnityftpServer
  Description: Information about the File Transfer Protocol (FTP) and Secure File Transfer Protocol (SFTP) servers of a NAS server. <br/> <br/> You can configure one FTP server and one SFTP server per NAS server. File Transfer Protocol (FTP) is a standard network protocol used to transfer files from one host to another host over a TCP-based network, such as the Internet. For secure transmission that encrypts the username, password, and content, FTP is secured with SSH (SFTP). <br/> <br/> You can activate an FTP server and SFTP server independently on each NAS server. The FTP and SFTP clients are authenticated using credentials defined on a Unix name server (such as an NIS server or a LDAP server) or a Windows domain. Windows user names need to be entered using the 'username@domain' or 'domain\username' formats. Each FTP and SFTP must have a home directory defined in the name server that must be accessible on the NAS server. FTP allows also clients to connect as anonymous users. <br/>  
#>
Class UnityftpServer {

  #Properties

  [String]$id #Unique identifier of the ftpServer instance.  
  [Object]$nasServer #NAS server that is configured with the FTP server.  
  [Bool]$isFtpEnabled #Indicates whether the FTP server is enabled on the NAS server specified in the nasServer attribute. Values are: <ul> <li> true - FTP server is enabled on the specified NAS server.</li> <li> false - FTP server is disabled on the specified NAS server.</li> </ul>  
  [Bool]$isSftpEnabled #Indicates whether the SFTP server is enabled on the NAS server specified in the nasServer attribute. Values are: <ul> <li> true - SFTP server is enabled on the specified NAS server.</li> <li> false - SFTP server is disabled on the specified NAS server.</li> </ul>  
  [Bool]$isCifsUserEnabled #Indicates whether FTP and SFTP clients can be authenticated using a CIFS user name. These user names are defined in a Windows domain controller, and their formats are user@domain or domain\user. Values are: <ul> <li> true - CIFS user names are accepted for authentication.</li> <li> false - CIFS user names are not accepted for authentication.</li> </ul>  
  [Bool]$isUnixUserEnabled #Indicates whether FTP and SFTP clients can be authenticated using a Unix user name. Unix user names are defined in LDAP or NIS servers. Values are: <ul> <li> true - Unix user names are accepted for authentication.</li> <li> false - Unix user names are not accepted for authentication.</li> </ul>  
  [Bool]$isAnonymousUserEnabled #Indicates whether FTP clients can be authenticated anonymously. Values are: <ul> <li> true - Anonymous user name is accepted.</li> <li> false - Anonymous user name is not accepted.</li> </ul>  
  [Bool]$isHomedirLimitEnabled #Indicates whether an FTP or SFTP user's area is limited to his or her home directory.. For information about CIFS home directories, see <i>Using a VNXe3200 System with CIFS File Systems</i>, which is available on the <a href="http://support.emc.com">EMC Online Support</a> website. Values are: <ul> <li> true - An FTP or SFTP user can access his or her own home directory only.</li> <li> false - FTP and SFTP users can access any NAS server directory, according to NAS server permissions.</li> </ul>  
  [String]$defaultHomedir #(Applies when the value of isHomedirLimitEnabled is false.) Default directory of FTP and SFTP clients who have a home directory that is not defined or accessible. This parameter is an absolute path relative to the root of the NAS server.  
  [String]$welcomeMsg #Welcome message displayed on the console of FTP and SFTP clients before their authentication. The length of this message is limited to 511 bytes, and the length of each line is limited to 80 bytes.  
  [String]$motd #Message of the day displayed on the console of FTP clients after their authentication. The length of this message is limited to 511 bytes, and the length of each line is limited to 80 bytes.  
  [Bool]$isAuditEnabled #Indicates whether the activity of FTP and SFTP clients is tracked in audit files. Values are: <ul> <li> true - FTP/SFTP activity is tracked.</li> <li> false - FTP/SFTP activity is not tracked.</li> </ul>  
  [String]$auditDir #(Applies when the value of isAuditEnabled is true.) Directory of FTP/SFTP audit files. This parameter is an absolute path relative to the root of the NAS server.  
  [Object]$auditMaxSize #(Applies when the value of isAuditEnabled is true.) Maximum size of FTP/SFTP audit files.  
  [String[]]$hostsList #Allowed or denied hosts, depending on the value of the isAllowHost attribute. A host is defined using its IP address. Subnets using CIDR notation are also supported. <ul> <li>If allowed hosts exist, only those hosts and no others can connect to the NAS server through FTP or SFTP.</li> <li>If denied hosts exist, they always have access denied to the NAS server through FTP or SFTP.</li> <li>If the list is empty, there is no restriction to NAS server access through FTP or SFTP based on the host IP.</li> </ul>  
  [String[]]$usersList #Allowed or denied users, depending on the value of the isAllowUser attribute. <ul> <li>If allowed users exist, only those users and no others can connect to the NAS server through FTP or SFTP.</li> <li>If denied users exist, they have always access denied to the NAS server through FTP or SFTP.</li> <li>If the list is empty, there is no restriction to the NAS server access through FTP or SFTP based on the user name.</li> </ul>  
  [String[]]$groupsList #Allowed or denied user groups, depending on the value of the isAllowGroup attribute. <ul> <li>If allowed groups exist, only users who are members of these groups and no others can connect to the NAS server through FTP or SFTP.</li> <li>If denied groups exist, all users who are members of those groups have always access denied to the NAS server through FTP or SFTP.</li> <li>If the list is empty, there is no restriction to the NAS server access through FTP or SFTP based on the user group.</li> </ul>  
  [Bool]$isAllowHost #Indicates whether the hostsList attribute contains allowed or denied hosts. Values are: <ul> <li> true - hostsList contains allowed hosts.</li> <li> false - hostsList contains denied hosts.</li> </ul>  
  [Bool]$isAllowUser #Indicates whether the usersList attribute contains allowed or denied users. Values are: <ul> <li> true - usersList contains allowed users.</li> <li> false - usersList contains denied users.</li> </ul>  
  [Bool]$isAllowGroup #Indicates whether the groupsList attribute contains allowed or denied user groups. Values are: <ul> <li> true - groupsList contains allowed user groups.</li> <li> false - groupsList contains denied user groups.</li> </ul>  

  #Methods

}

<#
  Name: UnityhostInitiatorPath
  Description: Information about host initiator paths in the storage system. Each initiator can be associated with multiple initiator paths. <br/> <br/>  
#>
Class UnityhostInitiatorPath {

  #Properties

  [String]$id #Unique identifier of the hostInitiatorPath instance.  
  [HostInitiatorPathTypeEnum]$registrationType #Indicates how the initiator in the path was registered to the host.  
  [Bool]$isLoggedIn #Indicates whether the host initiator is logged into the storage system. Values are: <ul> <li>true - Host initiator is logged into the storage system.</li> <li>false - Host initiator is not logged into the storage system.</li> </ul>  
  [String]$hostPushName #(Applies when the value of the registrationType attribute is set to ESXAuto.) Name of the host that is automatically associated with the initiator path through host push.  
  [String[]]$sessionIds #(Applies to iSCSI paths only.) Session identifiers in the host initiator path.  
  [Object]$initiator #Host initiator associated with the host initiator path, as defined by the hostInitiator resource type.  
  [Object]$iscsiPortal #(Applies to iSCSI paths only.) iSCSI portal, as defined by the iscsiPortal resource type.  

  #Methods

}

<#
  Name: UnityhostLUN
  Description: Information about the LUNs and LUN snapshots to which a host has access. <br/> <br/>  
#>
Class UnityhostLUN {

  #Properties

  [String]$id #Unique identifier of the hostLUN instance.  
  [Object]$host #Information about the host that has access to the LUN or LUN snapshot, as defined by the host resource type.  
  [HostLUNTypeEnum]$type #Indicates whether this instance of the hostLUN resource type represents a LUN or LUN snapshot.  
  [Object]$hlu #Host LUN Identifier (HLU) for the host storage group.  
  [Object]$lun #(Applies to LUNs only.) LUN, as defined by the lun resource type.  
  [Object]$snap #(Applies to LUN snapshots only.) LUN snapshot, as defined by the lunSnap resource type.  
  [Bool]$isReadOnly #Indicates whether the host access to the LUN or LUN snapshot is read-only. Values are: <ul> <li>true - Host access is read-only.</li> <li>false - Host access is read-write.</li> </ul>  
  [Bool]$isDefaultSnap #(Applies to LUN snapshots only.) Indicates whether this instance of the hostLUN resource type represents a default snapshot. <ul> <li>true - instance represents HLU for default snapshot.</li> <li>false - instance does not represent HLU for default snapshot</li> </ul>  

  #Methods

}

<#
  Name: UnityhostLunModify
  Description: Parameters used for modifying the HLU of a Host LUN. <br/> <br/> This embedded class type is passed to the ModifyHostLUNs method of the host object.  
#>
Class UnityhostLunModify {

  #Properties

  [Object]$hostLUN #Reference to the hostLUN to be modified.  
  [Object]$hlu #New host LUN ID (HLU) to be assigned to the LUN.  

  #Methods

}

<#
  Name: UnityhostVVolDatastore
  Description: Information about the VVolDatastore to which a host has access. <br/> <br/>  
#>
Class UnityhostVVolDatastore {

  #Properties

  [String]$id #Unique identifier of the hostVVolDatastore instance.  
  [Object]$storageResource #Information about the VVol Datastore, as defined by the storageResource type.  
  [Object]$host #Information about the host that has access to the VVol Datastore, as defined by the host resource type.  

  #Methods

}

<#
  Name: UnityimportSyncProgress
  Description: This embedded type represents the sync progress details for each iteration of synchronization.  
#>
Class UnityimportSyncProgress {

  #Properties

  [ImportStageEnum]$syncStage #Import synchronization stage.  
  [Object]$iteration #Sync iteration number.  
  [Object]$percentProgress #Sync percent progress.  

  #Methods

}

<#
  Name: UnityinstalledSoftwareVersion
  Description: Information about installed system software and language packs in the VNXe system.  
#>
Class UnityinstalledSoftwareVersion {

  #Properties

  [String]$id #Unique identifier of the installedSoftwareVersion instance.  
  [String]$version #Version of the installed software.  
  [Object]$revision #Revision number of the installed software.  
  [DateTime]$releaseDate #Release date of the installed software.  
  [Object[]]$languages #List of language pack information included in this release.  
  [String[]]$hotFixes #List of installed hotfixes for the installed software instance.  
  [Object[]]$packageVersions #List of relevant package names and the version number of the package.  

  #Methods

}

<#
  Name: UnityinstalledSoftwareVersionLanguage
  Description: List the language pack information (name, version) installed in the release  
#>
Class UnityinstalledSoftwareVersionLanguage {

  #Properties

  [String]$name #Name of the installed software language.  
  [String]$version #Version of the installed software language.  

  #Methods

}

<#
  Name: UnityinstalledSoftwareVersionPackages
  Description: List of relevant package information (name, version) installed in the release  
#>
Class UnityinstalledSoftwareVersionPackages {

  #Properties

  [String]$name #Name of the installed software package.  
  [String]$version #Version of the installed software package.  

  #Methods

}

<#
  Name: UnityinterfacePortPair
  Description: List of source system client interface and target system port pairs used to create a VDM import.  
#>
Class UnityinterfacePortPair {

  #Properties

  [String]$sourceInterfaceName #Source interface name of the interface port pair.  
  [Object]$targetPort #Target port of the interface port pair.  

  #Methods

}

<#
  Name: UnityioLimitParameters
  Description: IO limit settings for the storage resource. This resource type is embedded in the lunParameter and snap resource types.  
#>
Class UnityioLimitParameters {

  #Properties

  [Object]$ioLimitPolicy #IO limit policy that applies to the storage resource, as defined by the ioLimitPolicy resource type.  

  #Methods

}

<#
  Name: UnityioLimitPolicy
  Description: Set of I/O limit rules that you can apply to a storage resource. On GUI and CLI, ioLimitPolicy and ioLimitRule are combined for now since we only support one I/O limit rule per I/O limit policy.  
#>
Class UnityioLimitPolicy {

  #Properties

  [String]$id #Unique identifier of the ioLimitPolicy instance.  
  [String]$name #I/O limit policy name.  
  [String]$description #I/O limit policy description.  
  [Bool]$isShared #Indicates whether the I/O limits defined in the I/O limit policy are shared among all assigned storage resources. Values are: <ul> <li>true - I/O limits are shared. The total I/O of the set of storage resources with this policy is limited.</li> <li>false - (Default) I/O limits are not shared. The I/O limit applies to each storage resource individually.</li> </ul>  
  [Bool]$isPaused #Indicates whether I/O limit policy is paused. Values are: <ul> <li>true - I/O limit policy is paused.</li> <li>false - (Default) I/O limit policy is not paused.</li> </ul>  
  [IOLimitPolicyTypeEnum]$type #IO limit policy type.  
  [Object[]]$ioLimitRules #(DEPRECATED)The references of the rules associated with the I/O limit policy, as defined by the ioLimitRule resource type. Currently, only one rule is supported per policy.  
  [Object[]]$ioLimitRuleSettings #IO limit rules associated with the I/O limit policy, as defined by the ioLimitRuleSetting resource type. Currently, only one rule is supported per policy.  
  [Object[]]$luns #LUNs to which the I/O limit policy applies, as defined by the LUN resource type.  
  [Object[]]$snaps #Snaps to which the I/O limit policy applies, as defined by the snap resource type.  
  [IOLimitPolicyStateEnum]$state #IO limit policy state.  

  #Methods

}

<#
  Name: UnityioLimitRule
  Description: (DEPRECATED)Conditions under which the storage system applies I/O limits. On GUI and CLI, ioLimitPolicy and ioLimitRule are combined for now since we only support one I/O limit rule per I/O limit policy.  
#>
Class UnityioLimitRule {

  #Properties

  [String]$id #Unique identifier of the ioLimitRule instance.  
  [String]$name #I/O limit rule name.  
  [String]$description #I/O limit rule description.  
  [Object]$maxIOPS #Read/write IOPS limit.  
  [Object]$maxKBPS #Read/write KB/s limit.  
  [Object]$maxIOPSDensity #Read/write density-based IOPS limit.  
  [Object]$maxKBPSDensity #Read/write density-based KB/s limit.  
  [Object]$burstRate #The percentage of read/write IOPS and/or KBPS over the limits a storage object is allowed to process during a spike in demand.  
  [DateTime]$burstTime #How long a storage object is allowed to process burst traffic.  
  [DateTime]$burstFrequency #How often a storage object is allowed to process burst traffic for the duration of burst time  
  [Object]$ioLimitpolicy #Information about the I/O limit policy to which the I/O limit rule is assigned, as defined by the ioLimitPolicy resource type.  

  #Methods

}

<#
  Name: UnityioLimitRuleSetting
  Description: Set of Quality of Service (QoS) rules included in the Qos policy.  
#>
Class UnityioLimitRuleSetting {

  #Properties

  [String]$id #Unique identifier of the ioLimitRule instance.  
  [String]$name #I/O limit rule name.  
  [String]$description #I/O limit rule description.  
  [Object]$maxIOPS #Read/write IOPS limit.  
  [Object]$maxKBPS #Read/write KB/s limit.  
  [Object]$maxIOPSDensity #Read/write density-based IOPS limit.  
  [Object]$maxKBPSDensity #Read/write density-based KB/s limit.  
  [Object]$burstRate #The percentage of read/write IOPS and/or KBPS over the limits a storage object is allowed to process during a spike in demand.  
  [DateTime]$burstTime #How long a storage object is allowed to process burst traffic.  
  [DateTime]$burstFrequency #How often a storage object is allowed to process burst traffic for the duration of burst time  

  #Methods

}

<#
  Name: UnityioLimitSetting
  Description: Global I/O limit settings.  
#>
Class UnityioLimitSetting {

  #Properties

  [String]$id #Unique identifier of the ioLimitSetting instance.  
  [Bool]$isPaused #Indicates whether I/O limits are enabled on the storage resource. Values are: <ul> <li>true - I/O limits paused.</li> <li>false - I/O limits resumed.</li> </ul>  
  [Object]$activeControlledStorageObjects #number of storage resources and attached snapshots that are current put under I/O limit control  
  [Object]$maxActiveControlledStorageObjects #maximum number of storage resources and attached snapshots that can be put under I/O limit control  

  #Methods

}

<#
  Name: UnityiscsiNode
  Description: Information about the iSCSI nodes in the storage system. An iSCSI node represents a single iSCSI initiator or target. <br/> iSCSI nodes are created automatically on every non-aggregated Ethernet port except of ports used for management access.  
#>
Class UnityiscsiNode {

  #Properties

  [String]$id #Unique identifier of the iscsiNode instance.  
  [String]$name #iSCSI node name.  
  [Object]$ethernetPort #Ethernet port associated with the iSCSI Node. (Each Ethernet port can be associated with one iSCSI node.)  
  [String]$alias #Descriptive name of the iSCSI node. This name does not have to be unique.  

  #Methods

}

<#
  Name: UnityiscsiSettings
  Description: Global ISCSI settings.  
#>
Class UnityiscsiSettings {

  #Properties

  [String]$id #Unique instance identifier. This is a singleton resource, so the id is always 0.  
  [Bool]$isForwardCHAPRequired #If True, the iSCSI storage requires checking of the initiator. Forward CHAP secret, which is set for each initiator, otherwise the iSCSI storage does not require Forward CHAP.  
  [String]$reverseCHAPUserName #Reverse CHAP user name, empty string indicates that chap is not set yet.  
  [String]$forwardGlobalCHAPUserName #Forward global CHAP user name, empty string indicates that chap is not set yet.  
  [Object]$iSNSServer #iSNS server IP address, if configured.  

  #Methods

}

<#
  Name: Unityjob
  Description: Information about the jobs in the storage system. <br/> <br/> A job represents one management request, it consists of a series of tasks. <br/> A job could also contain a series of primitive REST API POST requests, each of which maps to a task in the job. Such job is known as "batch request job". <br/> Client can query the job instance to track its progress, results, and details of each task. <br/> <br/> When a job is failed, the system might leave hehind unneeded resources that consume space. You can manually delete any resources that were created for the failed job. <br/>  
#>
Class Unityjob {

  #Properties

  [String]$id #Unique identifier of the job instance.  
  [String]$description #Job description.  
  [JobStateEnum]$state #Current state of the job.  
  [DateTime]$stateChangeTime #Date and time of the last state change for the job.  
  [DateTime]$submitTime #Date and time when the job was submitted.  
  [DateTime]$startTime #Date and time when the job started.  
  [DateTime]$endTime #Date and time when the job ended.  
  [DateTime]$elapsedTime #Amount of time for which the job has been running.  
  [DateTime]$estRemainTime #Estimated time remaining until the job completes.  
  [Object]$progressPct #Approximate percentage of the job that has completed.  
  [Object[]]$tasks #Set of tasks within the job, as defined by the jobTask object.  
  [Object]$parametersOut #Output parameters and their values of what the job is calling.  
  [Object]$messageOut #Status messages for job  
  [Bool]$isJobCancelable #Is job cancelable  
  [Bool]$isJobCancelled #Is job cancelled  
  [String]$clientData #User-specified data for the job, provided by the client in the clientData request parameter.  
  [Object]$affectedResource #Primary resource affected by this job.  

  #Methods

}

<#
  Name: UnityjobTask
  Description: An embedded task within a job. A job consists a series of tasks. In case of batch request job, each jobTask maps to a primitive REST API POST request. <br/> <br/> For information about jobs, see the Help topic for the job resource type.  
#>
Class UnityjobTask {

  #Properties

  [String]$name #Task name.  
  [String]$description #Description of the task.  
  [String]$object #Object name of corresponding primitive REST API request if this jobTask belongs to a batch request job.  
  [String]$action #Name of associated request action if this jobTask belongs to a batch request job.  
  [JobTaskStateEnum]$state #Current state of the job task.  
  [Object[]]$messages #Message(s) for this task.  
  [Object]$parametersIn #Request body of associated request action. This is nearly the same as a primitive REST API POST request body except that it could use "@<step name>.<out parameter name>" notation, which implies using the output value of a previous step as input value.  
  [Object]$parametersOut #Output parameters and their values of what the associated request action is calling if this jobTask belongs to a batch request job.  
  [DateTime]$submitTime #Date and time when the jobTask was submitted if this jobTask belongs to a batch request job.  
  [DateTime]$startTime #Date and time when the jobTask started if this jobTask belongs to a batch request job.  
  [Object]$affectedResource #Primary resource affected by this task.  

  #Methods

}

<#
  Name: UnityjobTaskRequest
  Description: The batch job consists of a group of primitive REST API POST requests. Each is considered to be a task of the job. This object is to represent such primitive request. <br/> <br/> For information about jobs, see the Help topic for the job resource type.  
#>
Class UnityjobTaskRequest {

  #Properties

  [String]$name #Name of the task. Should be unique within a batch request job.  
  [String]$description #Description of the task. UTF-8 character message is acceptable.  
  [DateTime]$submitTime #Date and time when the jobTask was submitted.  
  [DateTime]$startTime #Date and time when the jobTask started.  
  [String]$object #Object name of corresponding primitive REST API request.  
  [String]$action #Name of associated request action.  
  [Object]$parametersIn #Request body of associated request action. This is nearly the same as a primitive REST API POST request body except that it could use "@<step name>.<out parameter name>" notation, which implies using the output value of a previous step as input value.  
  [String[]]$dependencies #jobTaskRequest name list. Current REST request will not be posted until the requests in the list are finished.  

  #Methods

}

<#
  Name: UnityldapServer
  Description: Information about the Lightweight Directory Access Protocol (LDAP) server used by the storage system as an authentication authority for administrative users. You can configure one LDAP server. The system uses the LDAP settings for facilitating access control to Unisphere and the Unisphere CLI, but not for facilitating access control to storage resources. <br/> <br/> LDAP is an application protocol for querying and modifying directory services running on TCP/IP networks. LDAP provides central management for network authentication and authorization operations by helping to centralize user and group management across the network. Integrating the system into an existing LDAP environment provides a way to control user and user group access to the system through Unisphere or the Unisphere CLI. <br/> <br/> After you configure LDAP settings for the system, you can manage users and user groups within the context of an established LDAP directory structure. For example, you can assign access permissions to the Unisphere CLI that are based on existing users and groups. <br/> <br/>  
#>
Class UnityldapServer {

  #Properties

  [Object]$timeout #Timeout for establishing a connection to an LDAP server. If the system does not receive a reply from the LDAP server before the specified timeout, it stops sending requests. <br/> <br/> Default value is 30000 (30 seconds).  
  [String]$id #Unique identifier of the ldapServer instance.  
  [String]$authority #Name of the LDAP authority.  
  [Object]$serverAddress #IP address of the LDAP server.  
  [String]$bindDN #Bind Distinguished Name (DN) of the user to be used when binding; that is, authenticating and setting up the connection to the LDAP Server. For example: Administrator@mycompany.com or cn=Administrator,cn=Users,dc=mycompany,dc=com  
  [LDAPProtocolEnum]$protocol #Protocol used to connect to the LDAP server.  
  [String]$userSearchPath #Path used to search for users on the directory server. For example: <br/> <br/> ou=People,dc=lss,dc=emc,dc=com  
  [String]$groupSearchPath #Path used to search for groups on the directory server. For example: <br/> <br/> uid=name,ou=people,dc=domaincomponent <br/> <br/> or <br/> <br/> dc=domain component  
  [String]$userIdAttribute #Name of the LDAP attribute whose value indicates the user ID. <br/> <br/> Default value is uid.  
  [String]$groupNameAttribute #Name of the LDAP attribute whose value indicates the group name. <br/> <br/> Default value is cn.  
  [String]$userObjectClass #LDAP object class for users. <br/> <br/> Default value is user. <br/> <br/> In Active Directory, groups and users are stored in the same directory path, and are in a class called group.  
  [String]$groupObjectClass #LDAP object class for groups. <br/> <br/> Default value is group. <br/> <br/> In Active Directory, groups and users are stored in the same directory path and are in a class called group.  
  [String]$groupMemberAttribute #Name of the LDAP attribute whose value contains the names of group members within a group. <br/> <br/> Default value is member.  

  #Methods

}

<#
  Name: UnitylocalizedMessage
  Description: List of name value pairs used to embed additional data in an object.  
#>
Class UnitylocalizedMessage {

  #Properties

  [String]$locale # 
  [String]$message # 

  #Methods

}

<#
  Name: UnityloginSessionInfo
  Description: Information about a REST API login session.  
#>
Class UnityloginSessionInfo {

  #Properties

  [Object]$idleTimeout #Number of seconds after last use until this session expires.  
  [String]$id #Unique identifier of the loginSessionInfo instance.  
  [Object]$user #Information about the user logged into this session, as defined by the user resource type.  
  [Object[]]$roles #List of roles for the user logged into this session, as defined by the role resource type.  
  [Bool]$isPasswordChangeRequired #Indicates whether the password must be changed in order to use this session created for built-in admin account. <br/> <br/> Values are: <ul> <li>true - Password must be changed.</li> <li>false - Password does not need to be changed.</li> </ul> <br/> For information about changing the password for a local user, see the Help topic for the user resource type.  

  #Methods

}

<#
  Name: UnitylunAdd
  Description: Parameters used for adding a LUN to a Consistency group. <br/> <br/> This resource type is embedded in the storageResource resource type.  
#>
Class UnitylunAdd {

  #Properties

  [Object]$lun #Existing LUN to add to the Consistency group. This LUN should not belong to any other Consistency group.  

  #Methods

}

<#
  Name: UnitylunCreate
  Description: LUN parameters used for creating a LUN when creating or modifying a Consistency group. <br/> <br/> This resource type is embedded in the storageResource resource type.  
#>
Class UnitylunCreate {

  #Properties

  [String]$name #LUN name unque to the storage system.  
  [String]$description #LUN description.  
  [Object]$lunParameters #(Required) Settings for the LUN, as defined by the lunParameters resource type.  

  #Methods

}

<#
  Name: UnitylunDelete
  Description: Parameters used for deleting a LUN when modifying a Consistency group. <br/> <br/> This resource type is embedded in the storageResource resource type.  
#>
Class UnitylunDelete {

  #Properties

  [Object]$lun #LUN to remove from the Consistency group and completely delete from the storage system. To remove the LUN from the Consistency group without deletion from the storage system put the LUN into lunRemove object.  
  [Bool]$forceSnapDeletion #Indicates whether to delete all LUN snapshots along with the LUN. Values are: <ul> <li>true - Delete all LUN snapshots.</li> <li>false - Do not delete LUN snapshots.</li> </ul>  

  #Methods

}

<#
  Name: UnitylunMemberReplication
  Description: Member lun element pair details in a replication session. Applies to block storage resource replications.  
#>
Class UnitylunMemberReplication {

  #Properties

  [ReplicationSessionStatusEnum]$srcStatus #Status of the source element.  
  [ReplicationSessionNetworkStatusEnum]$networkStatus #Status of the network on which the replication session exists.  
  [ReplicationSessionStatusEnum]$dstStatus #Status of the destination element in the replication session.  
  [String]$srcLunId #Unique identifier of the source element in the element pair.  
  [String]$dstLunId #Unique identifier of the destination element in the element pair.  

  #Methods

}

<#
  Name: UnitylunModify
  Description: Parameters used for modifying a LUN when modifying a Consistency group. <br/> <br/> This resource type is embedded in the storageResource resource type.  
#>
Class UnitylunModify {

  #Properties

  [Object]$lun #LUN to modify.  
  [String]$name #New name of the LUN unique to the storage system.  
  [String]$description #New LUN description.  
  [Object]$lunParameters #Settings for the LUN, as defined by the lunParameters.  

  #Methods

}

<#
  Name: UnitylunParameters
  Description: Settings for a LUN. <br/> <br/> This resource type is embedded in the storageResource resource type.  
#>
Class UnitylunParameters {

  #Properties

  [Object]$pool #(Applies only to create requests.) Storage pool from which to create the LUN.  
  [Bool]$isThinEnabled #(Applies only for create requests.) Indicates whether to enable thin provisioning for the LUN. Values are: <ul> <li>true - Enable thin provisioning.</li> <li>false - Disable thin provisioning.</li> </ul> <br/> <b>Note:</b> If you enable thin provisioning for a LUN, you cannot disable it later.  
  [Bool]$isCompressionEnabled #Indicates whether to enable inline compression for the LUN. Values are: <ul> <li>true - Enable compression(default) </li> <li>false - Disable compression </li> </ul>  
  [Object]$size #LUN size. The size is required in creation requests. In the modification requests the size parameter can be greater than the current LUN size in this case the LUN is expanded. To shrink the LUN size this parameter is less than the current LUN size. To allow shrink operation the parameter forceShrink must be set true.  
  [Object]$fastVPParameters #(Applies if FAST VP is supported on the system and the corresponding license is installed.) FAST VP settings for the LUN, as defined by the fastVPParameters.  
  [NodeEnum]$defaultNode #Storage Processor (SP) that owns the LUN. If not specified, the system chooses the default owner automatically.  
  [Object[]]$hostAccess #Host access settings for the LUN, as defined by the blockHostAccess embedded resource type.  
  [Object]$ioLimitParameters #IO limit settings for the LUN, as defined by the ioLimitParameters.  

  #Methods

}

<#
  Name: UnitylunRemove
  Description: Parameters used for removing a LUN from a Consistency group. <br/> <br/> This resource type is embedded in the storageResource resource type.  
#>
Class UnitylunRemove {

  #Properties

  [Object]$lun #LUN to remove from the Consistency group. The LUN removed from Consistency group is not deleted from the storage system and simply becomes a standalone LUN not associated with any Consistency group. A LUN removed from one Consistency group then can be added to another Consistency group. To also delete the LUN after removing it, use the deleteLun parameter instead.  

  #Methods

}

<#
  Name: Unitymessage
  Description: A message occurrence. This is also the message object returned in the body of non-2xx return code REST responses.  
#>
Class Unitymessage {

  #Properties

  [DateTime]$created #Time at which the message occurred.  
  [SeverityEnum]$severity # 
  [Object]$errorCode #Error code for this message.  
  [Object]$httpStatusCode #HTTP status code for this message when returned from a REST API request.  
  [Object[]]$messages #A list of localized strings for this message, as pairs of (locale, message_string).  
  [String[]]$messageArgs #Arguments to be filled in error message  

  #Methods

}

<#
  Name: UnitymetricCollection
  Description: Information about each metrics collection in the VNXe or Unisphere Central system.  
#>
Class UnitymetricCollection {

  #Properties

  [String]$id #Unique identifier of the metricCollection resource type.  
  [Object]$interval #Interval associated with the metrics collection.  
  [DateTime]$oldest #Date and time on which the oldest available metric data in the collection was collected.  
  [Object]$retention #Number of days for which the metric data in the collection will be retained.  

  #Methods

}

<#
  Name: UnitymetricService
  Description: Information about the metrics service configuration. There is only one occurrence of this resource type.  
#>
Class UnitymetricService {

  #Properties

  [Bool]$isHistoricalEnabled #Indicates whether historical metrics collection is enabled: <ul> <li>true - Historical metrics collection is enabled. <li>false - Historical metrics collection is disabled. </ul>  
  [Object]$id #Unique identifier of the metricService instance to modify. The value of this attribute is always 0, since it is a singleton resource type.  

  #Methods

}

<#
  Name: UnitymoveSession
  Description: Information about movesession. <br/> <br/> A customer environment is often ever-changing, and as a result the ability to deliver business continuity and flexibility is paramount. The new local LUN migration feature address this concern, by adding the ability to move LUNs and Consistency Groups between Pools on a system. Local LUN migration can be used to rebalance storage resources across Pools when customer activity changes and an individual Pool's usage becomes oversaturated. Another use case for local LUN migration is to provide LUNs with a destination when a Pool is to be decommissioned. By leveraging Unity's Transparent Data Transfer (TDX) engine, host access remains fully online during the migration session.  
#>
Class UnitymoveSession {

  #Properties

  [String]$id #Unique identifier of the session.  
  [Object]$sourceStorageResource #Storage resource to be moved.  
  [Object]$sourceMemberLun #The LUN being moved when the corresponding storageResource isn't specific enough, i.e. a Consistency Group member LUN or LUN VMFS Datastore.  
  [Object]$destinationPool #Destination pool for the move.  
  [UnityHealth]$health #The health of the session.  
  [Object]$progressPct #The progress of the session expressed as a percentage.  
  [Object]$currentTransferRate #The current transfer rate of the session in MB/sec.  
  [Object]$avgTransferRate #The average transfer rate of the session in MB/sec.  
  [DateTime]$estTimeRemaining #The estimated time remaining based on the current transfer rate.  
  [MoveSessionStateEnum]$state #The current state of the session. The session state represents the lifecycle of a session.  
  [MoveSessionStatusEnum]$status #The current session status of the TDX session.  
  [MoveSessionPriorityEnum]$priority #The priority of this storageResource move relative to other moves.  

  #Methods

}

<#
  Name: UnitynameValuePair
  Description: List of name value pairs used to embed additional data in an object.  
#>
Class UnitynameValuePair {

  #Properties

  [String]$name #Candidate description name.  
  [String]$value #Candidate description value.  

  #Methods

}

<#
  Name: UnitynfsShareCreate
  Description: Parameters used for creating an NFS share when creating or modifying a file system. <br/> <br/> This resource type is embedded in the storageResource resource type.  
#>
Class UnitynfsShareCreate {

  #Properties

  [String]$path #Local path to a location within the file system. <br/> <br/> With NFS, each share must have a unique local path. <font color=#0f0f0f>By default, the system creates a share to the root of the file system (top-most directory) at file system creation time. </font>This path specifies the unique location of the file system on the storage system. <br/> <br/> Before you can create additional shares within an NFS shared folder, you must create directories within it from a Linux/UNIX host that is connected to the file system. After a directory has been created from a mounted host, you can create a corresponding share and set access permissions accordingly.  
  [String]$name #Unique name of the NFS share.  
  [Object]$nfsShareParameters #Common NFS share attributes, as defined by the nfsShareParameters resource type.  

  #Methods

}

<#
  Name: UnitynfsShareDelete
  Description: Parameters used for deleting an NFS share when modifying a file system. <br/> <br/> This resource type is embedded in the storageResource resource type.  
#>
Class UnitynfsShareDelete {

  #Properties

  [Object]$nfsShare #NFS share to delete.  

  #Methods

}

<#
  Name: UnitynfsShareModify
  Description: Parameters used for modifying an NFS share when modifying a file system. <br/> <br/> This resource type is embedded in the storageResource resource type.  
#>
Class UnitynfsShareModify {

  #Properties

  [Object]$nfsShare #NFS share to modify.  
  [Object]$nfsShareParameters #NFS share settings, as defined by the nfsShareParameters resource type.  

  #Methods

}

<#
  Name: UnitynfsShareParameters
  Description: Settings for an NFS share. <br/> <br/> This resource type is embedded in the storageResource resource type.  
#>
Class UnitynfsShareParameters {

  #Properties

  [String]$description #NFS share description.  
  [Bool]$isReadOnly #Indicates whether the NFS share is read-only. Values are: <ul> <li>true - NFS share is read-only.</li> <li>false - NFS share is read-write.</li> </ul>  
  [NFSShareDefaultAccessEnum]$defaultAccess #Default access level for all hosts accessing the NFS share.  
  [NFSShareSecurityEnum]$minSecurity #Minimal security level that must be provided by a client to mount the NFS share.  
  [Object[]]$noAccessHosts #Hosts with no access to the NFS share or its snapshots, as defined by the host resource type.  
  [Object[]]$readOnlyHosts #Hosts with read-only access to the NFS share and its snapshots, as defined by the host resource type.  
  [Object[]]$readWriteHosts #Hosts with read-write access to the NFS share and its snapshots, as defined by the host resource type.  
  [Object[]]$rootAccessHosts #Hosts with root access to the NFS share and its snapshots, as defined by the host resource type.  

  #Methods

}

<#
  Name: UnitypingResult
  Description: Information about ping command result.  
#>
Class UnitypingResult {

  #Properties

  [Bool]$result #Ping result. True if accessible, False otherwise.  
  [Float]$latency #Latency in milliseconds  

  #Methods

}

<#
  Name: UnitypoolConfiguration
  Description: System-recommended pool configuration settings. Instances of this resource type contain the output of the pool resource type's RecommendAutoConfiguration operation. <br/>  
#>
Class UnitypoolConfiguration {

  #Properties

  [String]$name #Pool name.  
  [String]$description #Pool description.  
  [Object]$storageConfiguration #Recommended configuration of the storage tier in the recommended pool, as defined by the storageCapabilityEstimation resource type.  
  [Object]$alertThreshold #Threshold at which the system will generate notifications about the amount of space remaining in the pool, specified as a percentage with 1% granularity. <br/> <br/> This threshold is based on the percentage of allocated storage in the pool compared to the total pool size.  
  [Float]$poolSpaceHarvestHighThreshold #(Applies when the automatic deletion of snapshots based on pool space usage is enabled for the system and pool.) <br/> <br/> Pool used space high threshold at which the system will automatically delete snapshots in the pool, specified as a percentage with .01% granularity. <br/> <br/> This threshold is based on the percentage of used space in the pool compared to the total pool size. When the percentage of used space reaches this threshold, the system automatically deletes snapshots in the pool, until a low threshold is reached.  
  [Float]$poolSpaceHarvestLowThreshold #(Applies when the automatic deletion of snapshots based on pool space usage is enabled for the system and pool.) <br/> <br/> Pool used space low threshold under which the system will stop automatically deleting snapshots in the pool, specified as a percentage with .01% granularity. <br/> <br/> This threshold is based on the percentage of used pool space compared to the total pool size. When the percentage of used space in the pool falls below this threshold, the system stops the automatic deletion of snapshots in the pool, until a high threshold is reached.  
  [Float]$snapSpaceHarvestHighThreshold #(Applies when the automatic deletion of snapshots based on snapshot space usage is enabled for the system and the pool.) <br/> <br/> Snapshot used space high threshold at which the system will automatically delete snapshots in the pool, specified as a percentage with .01% granularity. <br/> <br/> This threshold is based on the percentage of space used by pool snapshots compared to the total pool size. When the percentage of space used by snapshots reaches this threshold, the system automatically deletes snapshots in the pool, until a low threshold is reached.  
  [Float]$snapSpaceHarvestLowThreshold #(Applies when the automatic deletion of snapshots based on snapshot space usage is enabled for the system and the pool.) <br/> <br/> Snapshot used space low threshold under which the system will stop automatically delete snapshots in the pool, specified as a percentage with .01% granularity. <br/> <br/> This threshold is based on the percentage of space used by pool snapshots compared to the total pool size. When the percentage of space used by pool snapshots falls below this threshold, the system stops the automatic deletion of snapshots in the pool, until a high threshold is reached.  
  [Bool]$isFastCacheEnabled #(Applies if a FAST Cache license is installed on the system.) Indicates whether the pool will be used in the FAST Cache. Values are: <ul> <li>true - FAST Cache will be enabled for this pool.</li> <li>false - FAST Cache will be disabled for this pool.</li> </ul>  
  [Bool]$isFASTVpScheduleEnabled #(Applies if a FAST VP license is installed on the storage system.) Indicates whether to enable scheduled data relocations for the pool. Values are: <ul> <li>true - Enable scheduled data relocations for the pool.</li> <li>false - Disable scheduled data relocations for the pool.</li> </ul>  
  [Bool]$isDiskTechnologyMixed #Indicates whether the pool contains disks with different disk technologies, such as FLASH, NL-SAS, and SAS. Values are: <ul> <li>true - Pool contains disks with different disk technologies.</li> <li>false - Pool does not contain disks with different disk technologies.</li> </ul>  
  [Object]$maxSizeLimit #Maximum pool capacity recommended for the storage system.  
  [Object]$maxDiskNumberLimit #Maximum number of disks recommended for the storage system.  
  [Bool]$isMaxSizeLimitExceeded #Indicates whether the total size of all recommended pools exceeds that allowed by the storage system. Values are: <ul> <li>true - Total size of all recommended pools exceeds that allowed by the storage system.</li> <li>false - Total size of all recommended pools does not exceed that alllowed by the storage system.</li> <ul>  
  [Bool]$isMaxDiskNumberLimitExceeded #Indicates whether the total number of disks in the recommended pools exceeds that allowed by the storage system. Values are: <ul> <li>true - Total size of all recommended pools exceeds that allowed by the storage system.</li> <li>false - Total size of all recommended pools does not exceed that alllowed by the storage system.</li> <ul>  
  [Bool]$isRPMMixed #Indicates whether the pool contains disks with different rotational speeds. Values are: <ul> <li>true - Pool contains disks with different rotational speeds.</li> <li>false - Pool does not contain disks with different rotational speeds.</li> </ul>  

  #Methods

}

<#
  Name: UnitypoolConsumer
  Description: poolConsumer class is representation of single object that consumes storage inside pools. There are two types of pool consumers: storage resources and NAS servers. NAS servers and storage resource except Consistency groups are always wholly allocated in one and only one storage pool. Consistency group can be allocated in more than one storage pool in case if the LUNs belonging to the group allocated in the different pools. The NAS servers consume space in the pool of constant size which is not changed once NAS server created.  
#>
Class UnitypoolConsumer {

  #Properties

  [String]$id #Unique ID of object.  

  #Methods

}

<#
  Name: UnitypoolConsumerAllocation
  Description: poolConsumerAllocation class represents size of pool's space allocated by the consumer (storageResources or nasServers) inside the pool. Most of consumers are always wholly allocated in one and only one storage pool. The only exception is consistencyGroup storage resource that can contain different LUNs that reside in different pools.  
#>
Class UnitypoolConsumerAllocation {

  #Properties

  [Object]$sizeAllocatedTotal #Total space allocated in the storage pool for the consumer object.  
  [Object]$snapsSizeAllocated #Space allocated in the storage pool for snapshots of the consumer object.  
  [String]$id #Unique ID of poolConsumerAllocation object.  
  [Object]$pool #Storage pool reference.  
  [Object]$consumer #The object allocated in the storage pool.  
  [PoolConsumerTypeEnum]$consumerType #Type of pool consumer object.  

  #Methods

}

<#
  Name: UnitypoolUnitConfiguration
  Description: (Applies to virtual deployments only.) Pool unit configuration for particular tier.  
#>
Class UnitypoolUnitConfiguration {

  #Properties

  [Object]$poolUnit #Pool Unit identifier.  

  #Methods

}

<#
  Name: UnitypoolUnitParameters
  Description: Parameters for adding a pool unit to a pool, or modifying a pool unit. At this time, only virtual disk type pool units can be modified.  
#>
Class UnitypoolUnitParameters {

  #Properties

  [Object]$poolUnit #Pool unit for which these parameters are being specified. Indeed it is Virtual Disk identifier, but in the future it can be the other pool unit object types allowed.  
  [String]$name #Pool unit name. Can be used for Virtual Disk modification only.  
  [TierTypeEnum]$tierType #Tier type. If virtualDisk tier type is unknown it can be specified at the time of adding to pool.  

  #Methods

}

<#
  Name: UnitypotentialHost
  Description: This class is used to hold discovered hosts of a vCenter or ESX Host.  
#>
Class UnitypotentialHost {

  #Properties

  [String]$name #Display name of the discovered ESX server  
  [String]$serverName #DNS name of ESX server  
  [String]$description #Description of ESX server  
  [String]$osName #OS name of ESX server  
  [String]$osVersion #OS version of ESX server  
  [String]$uuid #Vendor unique identifier of ESX server  
  [Object[]]$kernelIPs #Kernel IPs of ESX server  
  [Object[]]$mgmtIPs #Management IPs of ESX server  
  [String[]]$fcInitiators #Fibre channel initiators of ESX server  
  [String[]]$iscsiInitiators #Iscsi initiators of ESX server  
  [HostContainerPotentialHostMatchConditionEnum[]]$matchedConditions #How the discovered ESX hosts match the existing hosts already known to the array  
  [Object[]]$matchedHosts #Existing hosts that match the discovered vCenter/ESX Host  
  [HostContainerPotentialHostMatchConditionEnum[]]$matchedPotentialHostsConditions #How the potential ESX hosts conflict among themseleves  
  [String[]]$matchedPotentialHosts #The names of the other potential hosts that match this potential host in any way  
  [HostContainerPotentialHostImportOptionEnum]$importOption #How ESXi server can be imported  

  #Methods

}

<#
  Name: UnitypreferredInterfaceSettings
  Description: The preferred interface of NAS server is an interface from which all the non-local outbound connections of this NAS server are initiated. The non-local connections are those which hosts can be accessed from this NAS server interfaces only via some router (gateway). <p/> The preferred interfaces for IPv4 and IPv6 are independent from each other. During the replication, the production interfaces could be activated and deactivated automatically, so the separate preferred interface settings are required for production and backup & DR testing interfaces. For each NAS server, the following preferred interface settings exist: <ol> <li>Production interfaces, IPv4.</li> <li>Production interfaces, IPv6.</li> <li>Backup & DR testing interfaces, IPv4.</li> <li>Backup & DR testing interfaces, IPv6.</li> </ol> <p/> Each of these settings could be set to the explicit interface. If it isn't set, corresponding interface will be selected automatically. <p/> The acting preferred interfaces, one for IPv4 and one for IPv6, are selected among active interfaces by the following rules, ordered by priority (highest first): <ol> <li>Manually selected interfaces have priority over automatically selected ones.</li> <li>Production interfaces have priority over backup and DR testing ones.</li> <li>The interface with the default gateway has priority over one not having one.</li> <li>From the otherwise equal priority interfaces, one with the most routes has the priority.</li> <li>From the otherwise equal priority interfaces, one with the minimal value of IP address (Sic!) has the priority.</li> </ol> <p/> <b>Note: </b>During the replication, on the destination side, only Backup & DR testing interfaces could be active. <p/> For the automatic selection, the interface re-selected each time any of this NAS interfaces or routes are changed. If the interface has been explicitly selected as preferred and then deleted, this type/class group setting (e.g. "Production/IPv6") gets reset to automatic selection. <p/> During the replication, on the destination side, only the production interfaces settings could be overridden. It is controlled by the single flag both for IPv4 and IPv6 interfaces. Note that this flag is independent from the "override" flag of the interface itself. If an interface is explicitly selected as preferred and then overridden, the interface is kept preferred. <p/> The acting preferred interfaces are marked by the corresponding property value, fileInterface.isPreferred == true. To get the list of the acting preferred interfaces of a NAS server, iterate its interface list checking the isPreferred property.  
#>
Class UnitypreferredInterfaceSettings {

  #Properties

  [String]$id #Unique identifier of the Preferred Interface Settings object.  
  [Object]$nasServer #Identifier of the file server instance that uses this Preferred Interface Settings object. Only one Preferred Interface Settings object per file server is supported.  
  [Object]$productionIpV4 #Requested IPv4 production preferred interface  
  [Object]$productionIpV6 #Requested IPv6 production preferred interface  
  [Object]$backupIpV4 #Requested IPv4 backup preferred interface  
  [Object]$backupIpV6 #Requested IPv6 backup preferred interface  
  [Object]$sourceParameters #Requested production preferred interfaces of the source NAS server. <p/> On the destination side of the active replication session: <li>The replicated IPv4 and IPv6 production interface settings are returned in the sourceParameters.productionIpV4 and sourceParameters.productionIpV6 fields.</li> <li>Regardless of the replicationPolicy settings, this property returns the replicated settings.</li> Without the active replication session or on the source side of such session: <li>Property is not populated.</li>  
  [ReplicationPolicyEnum]$replicationPolicy #Acting replication policy of the production preferred interfaces. <p/> On the destination side of the active replication session: <li>"Replicated" means that the settings for the production IPv4 and IPv6 preferred interface settings are replicated from the source side.</li> <li>"Overridden" means that the settings for the production IPv4 and IPv6 preferred interface settings are overridden on the destination side.</li> Without the active replication session or on the source side of such session: <li>Property is not populated.</li>  

  #Methods

}

<#
  Name: UnitypreferredInterfaceSourceParameters
  Description: Information about preferred interface settings of the source NAS server.  
#>
Class UnitypreferredInterfaceSourceParameters {

  #Properties

  [Object]$productionIpV4 #Requested IPv4 production preferred interface of the source NAS server  
  [Object]$productionIpV6 #Requested IPv6 production preferred interface of the source NAS server  

  #Methods

}

<#
  Name: UnityquotaConfig
  Description: A quotaConfig instance represents the quota configuration of either a tree quota or a file system.  
#>
Class UnityquotaConfig {

  #Properties

  [String]$id #Unique identifier.  
  [Object]$filesystem #Associated file system.  
  [Object]$treeQuota #Associated tree quota. <br> Only available for quota configuration of a tree quota.  
  [QuotaPolicyEnum]$quotaPolicy #Quota policy.  
  [Bool]$isUserQuotaEnabled #Whether user quota is enabled. Values are: <ul> <li> true - start tracking usages for all users on a file system or a quota tree, and user quota limits would be enforced. </li> <li> false - stop tracking usages for all users on a file system or a quota tree, and user quota limits will not be enforced. </li> <ul>  
  [Bool]$isAccessDenyEnabled #Whether access will be denied when the limit is exceeded. Values are: <ul> <li> true - Attempts to allocate additional storage will fail with out of space error, when the quota hard limit is exceeded or the soft limit is exceeded and the grace period is expired. </li> <li> false - Attempts to allocate additional storage will not fail because of quota limits. </li> </ul>  
  [Object]$gracePeriod #Grace period of soft limits.  
  [Object]$defaultHardLimit #Default hard limit of user quotas and tree quotas.  
  [Object]$defaultSoftLimit #Default soft limit of user quotas and tree quotas.  
  [DateTime]$lastUpdateTimeOfTreeQuotas #When tree quotas within a file system were last successfully updated. <br> The value is null if it is a quotaConfig instance of a quota tree.  
  [DateTime]$lastUpdateTimeOfUserQuotas #When user quotas within a file system or a quota tree were last successfully updated.  

  #Methods

}

<#
  Name: UnityraidConfiguration
  Description: Possible RAID configurations for the pool tier. These configurations have the same RAID type (or RAID level) and different stripe widths (or RAID moduluses).  
#>
Class UnityraidConfiguration {

  #Properties

  [RaidTypeEnum]$raidType #RAID type (or RAID level) of the RAID configuration.  
  [Bool]$isDefault #Indicates whether the RAID configuration is the default RAID configuration for the associated storage tier. Values are: <ul> <li>true - RAID configuration is the default RAID configuration for the associated storage tier.</li> <li>false - RAID configuration is not the default RAID configuration for the associated storage tier.</li> </ul>  
  [Object[]]$stripeWidthConfig #List of supported stripe widths (or RAID moduluses) for the RAID type.  

  #Methods

}

<#
  Name: UnityraidGroupParameters
  Description: Parameters to create RAID group from the disks and add it to the pool. <br/>  
#>
Class UnityraidGroupParameters {

  #Properties

  [Object]$dskGroup #Disk Group identifier.  
  [Object]$numDisks #Number of disks.  
  [RaidTypeEnum]$raidType #RAID type (or RAID level).  
  [RaidStripeWidthEnum]$stripeWidth #Stripe width (or RAID modulus).  

  #Methods

}

<#
  Name: UnityremoteInterface
  Description: All local and remote replication interfaces from all remote system connection configurations.  
#>
Class UnityremoteInterface {

  #Properties

  [String]$id #Unique global identifier of the remoteInterface instance. This is combination of system serial number and the instance id as is from the remote system.  
  [String]$remoteId #Unique identifier of the remoteInterface instance as is from remote system.  
  [String]$name #User-specified remote interface name.  
  [Object]$address #IP address of the remote interface.  
  [Object]$remoteSystem #Unique identifier of the remote system, as defined by the remoteSystem resource type.  
  [NodeEnum]$node #SP or node owning this interface.  
  [ReplicationCapabilityEnum]$capability #This property indicates the capability of the interface for replication sessions Values are: <ul> <li>0 - interface is capable of participating in SYNC replication sessions <li>1 - interface is capable of participating in ASYNC replication sessions <li>2 - interface is capable of participating in both SYNC and ASYNC replication sessions </ul>  

  #Methods

}

<#
  Name: UnityremoteSyslog
  Description: Configuration information for storage system remote logging. <br/> <br/> When you configure remote logging, you must specify the network address of a host that will receive the log data. The remote host must be accessible from the storage system, and security for the log information must be provided through network access controls or the system security at the remote host. <br/> <br/> By default, the storage system transfers log information on port 514 using the UDP protocol.  
#>
Class UnityremoteSyslog {

  #Properties

  [String]$id #Unique identifier of the remoteSyslog instance.  
  [Object]$address #IP address of the host where the storage system stores the remote log information. By default, the storage system stores log information on port 514.  
  [IpProtocolTypeEnum]$protocol #Protocol used to transfer messages to the remote log. <br/> <br/> Default protocol is UDP.  
  [RemoteSyslogFacilityTypeEnum]$facility #Type of information to record in the remote system log. It is recommended that you specify 1 (User-level-Messages) for this value.  
  [Bool]$enabled #Indicates whether the logging to the remote log is enabled. Values are: <ul> <li>true - Logging to the remote log is enabled.</li> <li>false - Logging to the remote log is disabled.</li> </ul>  

  #Methods

}

<#
  Name: UnityremoteSystem
  Description: Information about remote storage systems that connect to the system to which you are logged in. The system uses the configuration to access and communicate with the remote system. For example, to use remote replication, create a configuration that specifies the remote system to use as the destination for the replication session.  
#>
Class UnityremoteSystem {

  #Properties

  [String]$id #Unique identifier of the remoteSystem instance.  
  [String]$name #System name as reported by system.name on remote system.  
  [String]$model #Model name of the remote system.  
  [String]$serialNumber #Serial number of the remote system.  
  [UnityHealth]$health #Health information for the remote system, as defined by the health resource type.  
  [String]$managementAddress #Management IP address of the remote system.  
  [String[]]$altManagementAddressList #Alternate management IP addresses of the remote system.  
  [ReplicationCapabilityEnum]$connectionType #Type of the replication connection to the remote system.  
  [String[]]$syncFcPorts #Fibre channel ports used for synchronous replication.  
  [String]$username #Username for accessing the remote system.  
  [Object[]]$localSPAInterfaces #SPA replication interface IP addresses of local system used in remote system connection configuration.  
  [Object[]]$localSPBInterfaces #SPB replication interface IP addresses of local system used in remote system connection configuration.  
  [Object[]]$remoteSPAInterfaces #SPA replication interface IP addresses of remote system used in remote system connection configuration.  
  [Object[]]$remoteSPBInterfaces #SPB replication interface IP addresses of remote system used in remote system connection configuration.  

  #Methods

}

<#
  Name: UnityreplicationInterface
  Description: Information about replication interfaces in the storage system. These interfaces are used in remote replication connections and sessions for replication data transfer.  
#>
Class UnityreplicationInterface {

  #Properties

  [String]$id #Unique identifier of the replicationInterface instance.  
  [Object]$ipPort #Physical port or link aggregation on the storage processor on which the replication interface is running, as defined by the ipPort resource type.  
  [UnityHealth]$health #Health of the replication interface, as defined by the health resource type.  
  [Object]$ipAddress #IP address of the replication interface.  
  [IpProtocolVersionEnum]$ipProtocolVersion #IP protocol version of the replication interface.  
  [Object]$netmask #IPv4 netmask for the replication interface, if it uses an IPv4 address.  
  [Object]$v6PrefixLength #IPv6 prefix length for the replication interface, if it uses an IPv6 address.  
  [Object]$gateway #IPv4 or IPv6 gateway address for the replication interface.  
  [Object]$vlanId #Virtual Local Area Network (VLAN) identifier for the replication interface. The interface uses the identifier to accept packets that have matching VLAN tags. <br/> <br/> Values are 0 - 4094. The default is 0, which means that the packets to accept do not have VLAN tags.  
  [String]$macAddress #MAC address of the virtual Ethernet port used for the replication interface. A physical Ethernet port has a different MAC address.  
  [String]$name #Replication interface name.  

  #Methods

}

<#
  Name: UnityreplicationParameters
  Description: Replication settings for the storage resource. <br/> <br/> This resource type is embedded in the storageResource resource type.  
#>
Class UnityreplicationParameters {

  #Properties

  [Bool]$isReplicationDestination #Indicates whether the storage resource is a replication destination. Values are: <ul> <li>true - Storage resource is a replication destination.</li> <li>false - (Default) Storage resource is not a replication destination.</li> </ul>  

  #Methods

}

<#
  Name: UnityreplicationSession
  Description: Information about replication sessions. <br/> <br/> Replication is a process in which storage data is duplicated either locally or to a remote network device. Replication produces a read-only, point-in-time copy of source data and periodically updates the copy, keeping it consistent with the source data. Replication provides an enhanced level of redundancy in case the main storage backup system fails. As a result, the: <ul> <li>Downtime associated cost of a system failure is minimized. <li>Recovery process from a natural or human-caused disaster is facilitated. </ul> A replication session establishes an end-to-end path for a replication operation between a source and a destination. The replication source and destination may be local or remote. The session establishes the path that the data follows as it moves from source to destination.  
#>
Class UnityreplicationSession {

  #Properties

  [String]$id #Unique identifier of the replicationSession instance.  
  [String]$name #User-specified replication session name.  
  [ReplicationEndpointResourceTypeEnum]$replicationResourceType #Replication resource type of replication session endpoints.  
  [ReplicationOpStatusEnum]$status #Replication status of the replication session.  
  [UnityHealth]$health #Health information for the replication session, as defined by the health resource type.  
  [Object]$maxTimeOutOfSync #Maximum time to wait before the system syncs the source and destination resources. Value of -1 specifies that automatic sync is not performed.  
  [ReplicationSessionStatusEnum]$srcStatus #Status of the source end of the session.  
  [ReplicationSessionNetworkStatusEnum]$networkStatus #Status of the network connection used by the replication session.  
  [ReplicationSessionStatusEnum]$dstStatus #Status of the destination end of the replication session.  
  [DateTime]$lastSyncTime #Date and time of the last replication synchronization.  
  [ReplicationSessionSyncStateEnum]$syncState #Synchronization state between source and destination resource of the replication session.  
  [Object]$remoteSystem #The remote system to which this replication session is connected, as defined by the remoteSystem resource type.  
  [ReplicationSessionReplicationRoleEnum]$localRole #Role of the local system in the replication session.  
  [String]$srcResourceId #Identifier of the source resource in the replication session.  
  [Object]$srcSPAInterface #SP A interface used on the source system for the replication, if the replication session is a remote session.  
  [Object]$srcSPBInterface #SP B interface used on the source system for the replication, if the replication session is a remote session.  
  [String]$dstResourceId #Identifier of the destination resource.  
  [Object]$dstSPAInterface #SP A interface used on the destination system for the replication, if the replication session is a remote session.  
  [Object]$dstSPBInterface #SP B interface used on the destination system for the replication, if the replication session is a remote session.  
  [Object[]]$members #Information about the replication of each member lun in the group.  
  [Object]$syncProgress #Synchronization completion percentage between source and destination resources of the replication session.  
  [Object]$currentTransferEstRemainTime #Estimated time left for the replication synchronization to complete.  

  #Methods

}

<#
  Name: UnityresourceInfo
  Description: This embedded type provided details of a resource.  
#>
Class UnityresourceInfo {

  #Properties

  [String]$resId #Identifier of the resource.  
  [String]$name #Name of the resource.  
  [Object]$system #System on which the resource exists.  

  #Methods

}

<#
  Name: UnityresourceRef
  Description: This is used to contain a reference to an instance where the class may vary. <Eng> A property or arg of this type, if mapped to an OSLS property/arg, means that the OSLS value is the instance id (instance name) of the target object. This can be looked up to find the class and id for this interface. </Eng>  
#>
Class UnityresourceRef {

  #Properties

  [String]$resource #The class name of the referenced instance.  
  [String]$id #The id of the referenced instance.  

  #Methods

}

<#
  Name: UnityrevokedCertificate
  Description: Settings for revoked certificates in the CRL. <br> <br> This resource type is embedded in the crl resource type. The CRL and revoked certificate formats are described in RFC 5280.  
#>
Class UnityrevokedCertificate {

  #Properties

  [String]$id #Unique identifier of the revokedCertificate instance.  
  [String]$serialNumber #Certificate serial number.  
  [DateTime]$revocationDate #Date and time when the certificate was revoked.  
  [CRLReasonCodeEnum]$reasonCode #Reason the certificate was revoked.  

  #Methods

}

<#
  Name: Unityrole
  Description: Information about the roles in the storage system. Each role identifies a level of authority for accessing and modifying the system.  
#>
Class Unityrole {

  #Properties

  [String]$id #Unique identifier of the role instance.  
  [String]$name #Name used to identify the role. Valid values are: <ul> <li>administrator - Administrator role. Can view status and performance information. Can also modify all storage system settings, including configure new storage hosts and manage local user, LDAP user, and LDAP group accounts.</li> <li>storageadmin - Storage administrator role. Can view status and performance information and can modify most system settings, but cannot configure new storage hosts or manage local user, LDAP user, or LDAP group accounts.</li> <li>vmadmin - VMware administrator role. Can establish a VASA connection from the vCenter to the storage system.</li> <li>operator - Operator role. Can view system settings, status, and performance information, but cannot modify system settings.</li> </ul>  
  [String]$description #Role description.  

  #Methods

}

<#
  Name: UnityroleMapping
  Description: Information about role mappings in the storage system. <br/> <br/> Each role mapping associates a local user, LDAP user, or LDAP group with a role, granting that user or group administrative privileges on the system. <br/> <br/> When you create a local user through the REST API, the appropriate role mapping between the new user and the specified role is created implicitly by the storage system. When you create an LDAP user or group through the REST API, you must explicitly specify a role mapping for that user or group by creating a new roleMapping resource. <br/> <br/> For information about creating local users, see the Help topic for the user resource type.  
#>
Class UnityroleMapping {

  #Properties

  [String]$id #Unique identifier of the roleMapping instance.  
  [String]$authorityName #Authority used to authorize the entity. Values are: <ul> <li>Local, for a local user.</li> <li>LDAP server authority name, for an LDAP user or group.</li)> </ul>  
  [String]$roleName #Role name to associate with the entity specified by the entityName attribute.  
  [String]$entityName #Local user, LDAP user, or LDAP group name to associate with the role specified by the roleName attribute.  
  [RoleMappingTypeEnum]$mappingType #Indicates whether the role mapping is for a local user, LDAP user, or LDAP group.  

  #Methods

}

<#
  Name: Unityroute
  Description: Manages static IP routes, including creating, modifying, and deleting these routes. <p/> A route determines where to send a packet next so it can reach its final destination. A static route is set explicitly and does not automatically adapt to the changing network infrastructure. A route is defined by an interface, destination IP address range and an IP address of a corresponding gateway. <p/> <b>Note: </b>IP routes connect an interface (IP address) to the larger network through gateways. Without routes, the interface is no longer accessible outside of its immediate subnet. As a result, network shares and exports associated with the interface are no longer available to clients outside their immediate subnet. <p/> Routes can be created only for iSCSI portals.  
#>
Class Unityroute {

  #Properties

  [String]$id #Unique identifier of the route instance.  
  [Object]$ipInterface #Reference to IP interface.  
  [Object]$iscsiPortal #Reference to iscsiPortal.  
  [Object]$fileInterface #Reference to file Interface.  
  [Object]$destination #IP address of the target network node based on the specific route type. Values are: <ul> <li>For a default route, there is no value, because the system will use the specified gateway IP address. <li>For a host route, the value is the IP address. <li>For a subnet route, the value is a subnet IP address. </ul>  
  [Object]$netmask #IPv4 netmask for the route, if it uses an IPv4 address.  
  [Object]$v6PrefixLength #IPv6 prefix length for the route, if it uses an IPv6 address.  
  [Object]$gateway #IP address of the gateway associated with the route.  
  [UnityHealth]$health #Health of the route. The health can be impaired if the corresponding interface is changed in a manner incompatible with the route. Modify the route to make it consistent with the interface to restore health to normal, or remove the route if no longer needed.  
  [Bool]$isRouteToExternalServices #Indicates whether this route is used for external services access like DNS, LDAP, NIS etc.  

  #Methods

}

<#
  Name: UnityrpChapSettings
  Description: CHAP accounts management for RPA cluster. RPA iSCSI ports act as initiators and log into storage targets, meanwhile, storage iSCSI ports act as initiators and log into RPA targets as well. For security reason, forward CHAP is supported on both directions. Outgoing forward CHAP account is used by storage ports to log into RPAs and incoming foward CHAP account is used by storage to authenticate RPA initiators. However, for now incoming forward account is managed by iscsiSettings and it will be moved here in later releases.  
#>
Class UnityrpChapSettings {

  #Properties

  [String]$id #Unique instance identifier.  
  [String]$outgoingForwardChapUsername #Outgoing Forward CHAP user name, null string indicates chap not set.  

  #Methods

}

<#
  Name: UnitysecuritySettings
  Description: All the system level security settings. <br/> Use this resource to enable and disable system level security settings. <br/> The settings include: <br/> <br/> a) FIPS 140-2 <br/> Information about whether the system is working in Federal Information Processing Standard (FIPS) 140-2 mode. <br/> <br/> The storage systems support FIPS 140-2 mode for the RSA BSAFE SSL modules on the storage pocessor that handle client management traffic. Management communication into and out of the system is encrypted using SSL. As a part of this process, the client and the Storage Management Server negotiate a cipher suite to use in the exchange. The use of FIPS 140-2 mode restricts the allowable set of cipher suites that can be selected in the negotiation to those that are sufficiently strong. <br/> <br/> If FIPS 140-2 mode is enabled, you may find that some of your existing clients can no longer communicate with the management ports of the array if they do not support a cipher suite of acceptable strength. <br/> <br/> b) SSO <br/> Information about whether the system is participating in Single Sign On mode. <br/> <br/> In Single Sign On (SSO) mode, Unisphere Central (UC) becomes the authentication server for multiple storage system, thus creating a shared authentication domain where cross-array operations can be performed without re-entering user credentials. <br/> <br/> If SSO is enabled, the system will participate in Single Sign On mode, and authenticate against Unisphere Central previously configured on this array. <br/> <br/> c) TLS 1.0 <br/> Information about whether the Storage Management Server allows SSL communication using the TLS 1.0 protocol. <br/> <br/> Management communication into and out of the Storage Management Server is encrypted using SSL. As a part of this process, the client and the Storage Management Server negotiate a SSL protocol to use. By default, the Storage Management Server supports TLS 1.0, TLS 1.1 and TLS 1.2 protocols for SSL communications. Disabling the TLS 1.0 protocol using this setting means that the Storage Management Server will only support SSL communications using the TLS 1.1 and TLS 1.2 protocols and TLS 1.0 will not be considered a valid protocol. <br/> <br/> Disabling TLS 1.0 may impact existing client applications which are not compatible with TLS 1.1 or TLS 1.2 protocols. In this case, TLS 1.0 support should remain enabled. <br/> <br/>  
#>
Class UnitysecuritySettings {

  #Properties

  [String]$id #Unique identifier of the securitySettings instance. The value of this attribute is always 0, because securitySettings is a singleton resource type.  
  [Bool]$isFIPSEnabled #Indicates whether the system is working in FIPS 140-2 mode. Values are: <ul> <li>true - System is working in FIPS 140-2 mode.</li> <li>false - System is not working in FIPS 140-2 mode.</li> </ul>  
  [Bool]$isSSOEnabled #Indicates whether the system has SSO enabled or not. Values are: <ul> <li>true - System is participating in SSO</li> <li>false - System is not participating in SSO</li> </ul>  
  [Bool]$isTLS1Enabled #Indicates whether the system has TLS 1.0 enabled or not. Values are: <ul> <li>true - TLS 1.0 is enabled</li> <li>false - TLS 1.0 is disabled</li> </ul>  

  #Methods

}

<#
  Name: UnityserviceAction
  Description: Information about storage system service actions. <br/> <br/> Collect Service Information (dataCollection): Collect information about the storage system and save it to a file. Your service provider can use the collected information to analyze the storage system. <br/> <br/> Save Configuration (configCapture): Save details about the configuration settings on the storage system to a file. Your service provider can use this file to assist you with reconfiguring your system after a major system failure or a system reinitialization. <br/> <br/> Restart Management Software (restartMGT): Restart the management software to resolve connection problems between the system and Unisphere. <br/> <br/> Reinitialize (reinitialize): Reset the storage system to the original factory settings. Both SPs must be installed and operating normally be in Service Mode. <br/> <br/> Change Service Password (changeServicePassword): Change the service password for accessing the Service System page. <br/> <br/> Shut Down System (shutdownSystem): The system shut down and power cycle procedures will attempt to resolve problems with your storage system that could not be resolved by rebooting or reimaging the SP. <br/> <br/> Disable SSH/Enable SSH (changeSSHStatus): Disable the Secure Shell (SSH) protocol to block SSH access to the system, or enable the Secure Shell (SSH) protocol to enable access to the system. <br/> <br/> Enter Service Mode (enterServiceModeSPA, enterServiceModeSPB): Stop I/O on the SP so that the SP can enter service mode safely. <br/> <br/> Reboot (rebootSPA, rebootSPB): Reboot the selected SP. Use this service action to attempt to resolve minor problems related to system software or SP hardware components. <br/> <br/> Reimage (rebootSPA, rebootSPB): Reimage the selected SP. Reimaging analyzes the system software on the SP and attempts to correct any problems automatically. <br/> <br/> Reset and Hold(resetAndHoldSPA, resetAndHoldSPB): Reset and hold the selected SP. Use this service task to attempt to reset and hold the SP, so that users can replace the faulty IoModule(s) on that SP. <br/> <br/>  
#>
Class UnityserviceAction {

  #Properties

  [String]$id #Unique identifier of the serviceAction instance.  
  [SvcScopeEnum]$scope #Current service action scope.  
  [String]$name #Localized service action name.  
  [String]$description #Localized service action description.  
  [Bool]$isApplicable #Indicates whether the service action can be executed. Values are: <ul> <li>true - Service action can be executed.</li> <li>false - Service action cannot be executed.</li> </ul>  
  [String]$applyCondition #Localized description of the condition under which the service action is applicable.  

  #Methods

}

<#
  Name: UnityserviceContract
  Description: (Applies if EMC Support is available.) Information about service contracts.  
#>
Class UnityserviceContract {

  #Properties

  [String]$id #Unique identifier of the serviceContract instance.  
  [Object]$contractId #Unique service contract identifier.  
  [String]$contractNumber #Contract number generated for the customer.  
  [ServiceContractStatusEnum]$contractStatus #Current service contract status.  
  [String]$levelOfService #Level of service that the service contract provides.  
  [String]$serviceLineId #Service offering identifier.  
  [DateTime]$lastUpdated #Date of last service contract renewal.  
  [DateTime]$productStartDate #Service contract start date.  
  [DateTime]$productEndDate #Service contract end date.  

  #Methods

}

<#
  Name: UnityserviceInfo
  Description: Service-related storage system information. You can use this information for servicing the storage system. <br/> <br/>  
#>
Class UnityserviceInfo {

  #Properties

  [String]$id #Unique identifier of the serviceInfo instance. Because serviceInfo is a singleton resource type, the value of this field is always 0.  
  [String]$productName #Product name, for example, Unity400. Usually, it's same as the system.model.  
  [String]$productSerialNumber #Product serial number. This has the same value as system.serialNumber.  
  [String]$systemUUID #(Applies to virtual deployments only.) Unique system identifier required to service the storage system.  
  [Bool]$isSSHEnabled #Indicates whether Secure Shell (SSH) is enabled on the storage system. Values are: <ul> <li>true - SSH is enabled.</li> <li>false - SSH is not enabled.</li> </ul>  
  [EsrsStatusEnum]$esrsStatus #Indicates ESRS status. This doesn't contain meaningful value and will removed soon  This attribute is obsolete and will be removed in a future release.  Please use esrsParam.status instead.
  [Object[]]$sps #Storage processor information, as defined by the svcStorageProcessor resource type.  

  #Methods

}

<#
  Name: Unitysite
  Description: Description of the physical address or site where EMC thinks this system is currently located. <br/>  
#>
Class Unitysite {

  #Properties

  [String]$siteId #Unique identifier of the site instance.  
  [String]$siteName #Site name.  
  [String]$siteDescription #Site description.  
  [String]$address #The address of the site where the system is located.  
  [String]$state #The state of the site where the system is located.  
  [String]$country #The country of the site where the system is located.  
  [String]$countryName #The country name where the system is located.  
  [String]$city #The city of the site where the system is located.  
  [Bool]$isCurrentLocation #True, when this is the site at which EMC believes the system is currently residing.  

  #Methods

}

<#
  Name: UnitysnapHostAccess
  Description: Host access settings for snapshot.  
#>
Class UnitysnapHostAccess {

  #Properties

  [Object]$host #Host that has access to the snapshot, as defined by the host resource type.  
  [SnapAccessLevelEnum]$allowedAccess #Access-level permissions for host.  

  #Methods

}

<#
  Name: UnitysnapHostAccessParameters
  Description: Host access settings for snapshot.  
#>
Class UnitysnapHostAccessParameters {

  #Properties

  [Object]$host #Host to grant access to snapshot, as defined by host type.  
  [SnapAccessLevelEnum]$allowedAccess #Access-level permissions for host.  

  #Methods

}

<#
  Name: UnitysnapScheduleParameters
  Description: Snapshot schedule settings for the storage resource. <br/> <br/> This resource type is embedded in the storageResource resource type.  
#>
Class UnitysnapScheduleParameters {

  #Properties

  [Object]$snapSchedule #Snapshot schedule assigned to the storage resource, as defined by the snapSchedule type.  
  [Bool]$isSnapSchedulePaused #Indicates whether the assigned snapshot schedule is paused. Values are: <ul> <li>true - Assigned snapshot schedule is paused.</li> <li>false - Assigned snapshot schedule is not paused.</li> </ul>  

  #Methods

}

<#
  Name: UnitysoftwareUpgradeSession
  Description: Information about a storage system upgrade session. <br/> <br/> Create an upgrade session to upgrade the system software or view existing upgrade sessions. The upgrade session installs an upgrade candidate file that was uploaded to the system. Download the latest upgrade candidate from EMC Online Support website. Use the CLI to upload the upgrade candidate to the system before creating the upgrade session. For information, see the <i>Unisphere CLI User Guide</i>. <br/> <br/> The latest software upgrade candidate contains all available hot fixes. If you have applied hot fixes to your system, the hot fixes are included in the latest upgrade candidate. <br/> <br/> <b>Note: </b>All system components must be healthy prior to upgrading the system software. If any system components are degraded, the software update will fail.  
#>
Class UnitysoftwareUpgradeSession {

  #Properties

  [String]$id #Unique identifier for the softwareUpgradeSession instance.  
  [UpgradeSessionTypeEnum]$type #Type of software to upgrade.  
  [Object]$candidate #Candidate software to install in the upgrade session, as defined by the candidateSoftwareVersion resource type.  
  [String]$caption #Caption for this upgrade session.  
  [UpgradeStatusEnum]$status #Status of the current upgrade session.  
  [Object[]]$messages #List of upgrade messages.  
  [DateTime]$creationTime #Date and time when the upgrade session was started.  
  [DateTime]$elapsedTime #Amount of time for which the upgrade session was running.  
  [Object]$percentComplete #Percentage of the upgrade that is completed.  
  [Object[]]$tasks #Current upgrade activity in the upgrade session, as defined by the upgradeTask resource type.  

  #Methods

}

<#
  Name: Unityssc
  Description: (Applies to physical deployments only.) Information about System Status Cards (SSCs) in the storage system.  
#>
Class Unityssc {

  #Properties

  [String]$id #Unique identifier of the ssc.  
  [UnityHealth]$health #Health information for the SSC, as defined by the health resource type.  
  [Bool]$needsReplacement #Indicates whether the SSC needs replacement. Values are: <ul> <li>true - SSC needs replacement.</li> <li>false - SSC does not need replacement.</li> </ul>  
  [Object]$parent #Resource type and unique identifier for the SSC's parent enclosure.  
  [Object]$slotNumber #Slot where the SSC is located in the parent enclosure.  
  [String]$name #SSC name.  
  [Object]$parentDae #Parent Disk Array Enclosure (DAE) of the SSC.  
  [String]$manufacturer #Manufacturer of the SSC.  
  [String]$model #Manufacturer's model number for the SSC.  
  [String]$emcPartNumber #EMC part number for the SSC.  
  [String]$emcSerialNumber #EMC serial number for the SSC.  
  [String]$vendorPartNumber #Vendor part number for the SSC.  
  [String]$vendorSerialNumber #Vendor serial number for the SSC.  

  #Methods

}

<#
  Name: Unityssd
  Description: (Applies to physical deployments only.) Information about internal Flash-based Solid State Disks (SSDs, mSATAs) in the storage system.  
#>
Class Unityssd {

  #Properties

  [String]$id #Unique identifier of the ssd.  
  [UnityHealth]$health #Health information for the SSD, as defined by the health resource type.  
  [Bool]$needsReplacement #Indicates whether the SSD needs replacement. Values are: <ul> <li>true - SSD needs replacement.</li> <li>false - SSD does not need replacement.</li> </ul>  
  [Object]$parent #Resource type and unique identifier for the SSD's parent enclosure.  
  [Object]$slotNumber #Slot where the SSD is located in the parent enclosure.  
  [String]$name #SSD name.  
  [String]$manufacturer #Manufacturer of the SSD.  
  [String]$model #Manufacturer's model number for the SSD.  
  [String]$firmwareVersion #SSD firmware revision number.  
  [String]$emcPartNumber #EMC part number for the SSD.  
  [String]$emcSerialNumber #EMC serial number for the SSD.  
  [String]$vendorPartNumber #Vendor part number for the SSD  
  [String]$vendorSerialNumber #Vendor serial number for the SSD.  
  [Object]$parentStorageProcessor #Parent storage processor of the ssd.  

  #Methods

}

<#
  Name: UnitystatValue
  Description: A statValue object contains one real-time sample of a single metric. Its JSON representation is the following: statValue {} { values } values pair pair , values pair string : value value float statValue The string in a pair is the ID of an object. The value is the metric value for that object.  
#>
Class UnitystatValue {

  #Properties


  #Methods

}

<#
  Name: UnitystorageProcessor
  Description: Information about Storage Processors (SPs) in the storage system.  
#>
Class UnitystorageProcessor {

  #Properties

  [String]$id #Unique identifier of the storageProcessor instance.  
  [Object]$parent #Resource type and unique identifier for the SP's parent enclosure.  
  [UnityHealth]$health #Health information for the SP, as defined by the health resource type.  
  [Bool]$needsReplacement #Indicates whether the SP needs replacement. Values are: <ul> <li>true - SP needs replacement.</li> <li>false - SP does not need replacement.</li> </ul>  
  [Bool]$isRescueMode #Indicates whether the SP is in Service Mode. Values are: <ul> <li>true - SP is in Service Mode.</li> <li>false - SP is not in Service Mode.</li> </ul>  
  [String]$model #Manufacturer's model number for the SP.  
  [Object]$slotNumber #Slot where the SP is located in the parent enclosure.  
  [String]$name #SP name.  
  [String]$emcPartNumber #EMC part number for the SP.  
  [String]$emcSerialNumber #EMC serial number for the SP.  
  [String]$manufacturer #Manufacturer of the SP.  
  [String]$vendorPartNumber #Vendor part number for the SP.  
  [String]$vendorSerialNumber #Vendor serial number for the SP.  
  [String]$sasExpanderVersion #Version number of the SAS Expander associated with the SP.  
  [String]$biosFirmwareRevision #Version number of the SP BIOS.  
  [String]$postFirmwareRevision #Version number of the SP Power-On Self-Test software.  
  [Object]$memorySize #SP RAM size.  
  [Object]$parentDpe #Parent Disk Processor Enclosure (DPE) of the storage processor.  
  [String]$uuid #(Applies to virtual deployments only.) SP UUID.  

  #Methods

}

<#
  Name: UnitystorageResourceCapabilityProfile
  Description: An association between a capability profile and a datastore-type storage resource, with capacity usage information about virtual volumes provisioned accordingly.  
#>
Class UnitystorageResourceCapabilityProfile {

  #Properties

  [String]$id #Unique identifier of the storage resource capability profile.  
  [Object]$storageResource #The datastore-type storage resource instance.  
  [Object]$capabilityProfile #Reference to the supported capability profile.  
  [Bool]$isInUse #True, if any VVol's are provisioned in the storage resource with the given capability profile.  
  [Object]$sizeUsed #Used size of virtual volumes provisioned in this storage resource (datastore) using this capability profile.  
  [Object]$sizeAllocated #Storage element allocated size per allocation pool, associated with required capability profile.  
  [Object]$sizeTotal #The maximum capacity, that could be used by the storage element per allocation pool, associated with required capability profile.  
  [Object]$logicalSizeUsed #The maximum capacity, that the storage elements of required capability profile are allowed to use from required pool.  

  #Methods

}

<#
  Name: UnitystorageResourceDelete
  Description: Parameters used for deleting a storage resource when deleting a batch of storage resources. <br/> <br/> This resource type is embedded in the storageResource resource type.  
#>
Class UnitystorageResourceDelete {

  #Properties

  [Object]$storageResource #Storage resource to completely delete from the storage system.  
  [Bool]$forceSnapDeletion #Indicates whether to delete a storage resource's snapshots along with the storage resource. . Values are: <ul> <li>true - Delete all the storage resource's snapshots.</li> <li>false - Do not delete the storage resource's snapshots.</li> </ul>  
  [Bool]$forceVVolsDeletion #Indicates whether to delete all VVols of the VVol datastore along with the storage resource. Values are: <ul> <li>true - Delete all VVols of the VVol datastore.</li> <li>false - Do not delete all VVols of the VVol datastore.</li> </ul>  

  #Methods

}

<#
  Name: UnitystorageTier
  Description: Set of possible RAID configurations that a storage tier can support. (A storage tier is the collection of all disks of a particular type on the storage system.) For example, if you have 11 disks in a tier, you can support R5 (4+1), R5 (8+1), but not R5(12+1). <br/> <br/> Use this resource type to create custom pools. For more information, see the help topic for the pool resource type. <br/> <br/>  
#>
Class UnitystorageTier {

  #Properties

  [String]$id #Unique identifier of the storageTier instance.  
  [TierTypeEnum]$tierType #Tier type.  
  [Object[]]$raidConfigurations #Possible RAID configurations for the storage tier, as defined by the raidConfiguration embedded object.  
  [Object]$disksTotal #Total number of disks in the storage system that have the same storage tier type as that specified by the tierType attribute.  
  [Object]$disksUnused #Total number of unused disks in the storage system that have the same tier type as that specified by the tierType attribute.  
  [Object]$virtualDisksTotal #Total number of virtual disks in the storage system that have the same tier type as that specified by the tierType attribute.  
  [Object]$virtualDisksUnused #Total number of unused virtual disks in the storage system that have the same tier type as that specified by the tierType attribute.  
  [Object]$sizeTotal #Total raw capacity of all physical disks and virtual disks in the storage system that have the same tier type as that specified by the tierType attribute.  
  [Object]$sizeFree #Total raw capacity of all unused physical disks and virtual disks in the storage system that have the same tier type as that specified by the tierType attribute.  

  #Methods

}

<#
  Name: UnitystorageTierConfiguration
  Description: Possible disk selections for a storage tier, given a specified storage tier type, RAID type, and stripe width. <br/> <br/> Use this resource type, along with the pool, diskGroup, and storageTier resource types, to create custom pools. For more information, see the help topic for the pool resource type.  
#>
Class UnitystorageTierConfiguration {

  #Properties

  [Object]$storageTier #Storage tier for which you want to obtain proposed configurations as defined by the storageCapability resource type.  
  [Object]$sizeTotal #Maximum usable capacity for the specified storage configuration if all available disks are used for the configuration.  
  [Object[]]$poolUnitConfigurations #(Applies to virtual deployments only.) List of pool units to use in the storage tier configuration.  

  #Methods

}

<#
  Name: UnitystorageTierExtension
  Description: Set of RAID configurations for each storage tier that can be used for pool expansion.  
#>
Class UnitystorageTierExtension {

  #Properties

  [TierTypeEnum]$tierType #Tier type.  
  [Object[]]$raidConfigurations #List of RAID configurations that can be used to expand the specified tier type, as defined by the raidConfiguration type.  

  #Methods

}

<#
  Name: UnitystripeWidthConfiguration
  Description: Possible stripe width (or RAID modulus) values for the specified RAID type and tier type.  
#>
Class UnitystripeWidthConfiguration {

  #Properties

  [String]$id #Unique identifier of the stripeWidthConfiguration instance. This identifier can be used to find corresponding profile in CLI.  
  [RaidStripeWidthEnum]$stripeWidth #RAID group stripe width.  
  [Object]$parityDisks #Number of parity disks.  
  [Object]$sizePotential #Maximum usable capacity. The system calculates this figure by summing up the capacities of all available disks that have the required disk type, RAID type, and stripe width.  
  [Bool]$isDefault #Indicates whether the stripe width is the default stripe width for the associated RAID type. Values are: <ul> <li>true - Stripe width is the default stripe width for the associated RAID type.</> <li>false - Stripe width is not the default stripe width for the associated RAID type.</> </ul>  

  #Methods

}

<#
  Name: UnitysupportAsset
  Description: Information about the support assets on the main Unisphere Support page and its sub-pages. <br/> <br/>  
#>
Class UnitysupportAsset {

  #Properties

  [String]$id #Unique identifier of the supportAsset instance.  
  [String]$name #Localized support asset name.  
  [String]$description #Localized support asset description.  

  #Methods

}

<#
  Name: UnitysupportProxy
  Description: Proxy Server settings. <p/> A proxy server is a server that acts as an intermediary for requests from clients seeking resources from other servers. <p/> The system uses the proxy server (if it's enabled) to access EMC web services such as authenticate support credential, get technical advisories, etc.  
#>
Class UnitysupportProxy {

  #Properties

  [String]$id #Unique identifier of the support proxy instance. --eng This value is always 0, because at any given time there is only one proxy.  
  [Bool]$isEnabled #Indicates whether the proxy server is enabled. <br/> Values are: <ul> <li>true - Uses proxy server</li> <li>false - Does not use proxy server</li> </ul>  
  [ProxyProtocolEnum]$protocol #Protocol used for communication with the proxy Server.  
  [Object]$address #Support proxy Server. <br/> If a port is not specified the following default ports will be used: <ul> <li>Protocol = http, Default port = 3128</li> <li>Protocol = socks, Default port = 1080</li> </ul>  
  [String]$username #The user name for proxy server.  

  #Methods

}

<#
  Name: UnitysupportService
  Description: (Applies if EMC Support is available.) Information about the support services associated with customers.  
#>
Class UnitysupportService {

  #Properties

  [String]$id #Unique identifier of the supportService instance.  
  [String]$supportUsername #Username for logging into EMC Support.  
  [SupportCredentialStatusEnum]$supportCredentialStatus #Status of the support credentials.  
  [Bool]$isEMCServiced #Indicates whether the customer has a valid EMC self-service support ecosystem license or service contract. <br/> Valid values are: <ul> <li>true - Customer has a valid EMC self-service support ecosystem license or service contract.</li> <li>false - Customer does not have a valid self-service support ecosystem license or service contract. </li> </ul>  
  [Bool]$isContractReportEnabled #Indicates whether the storage system automatically updates its service contracts list once a week. Values are: <ul> <li>true - System automatically updates its service contracts list once a week.</li> <li> false - System does not automatically update its service contracts list once a week.</li> </ul>  
  [Bool]$isCloudManagementEnabled #Indicates whether the customer has enabled management by the EMC Cloud Management product. <br/> Valid values are: <ul> <li>true - Customer has enabled Cloud Management.</li> <li>false - Customer has not enabled Cloud Management. </li> </ul>  

  #Methods

}

<#
  Name: UnitysvcCRU
  Description: Service-related information for the Customer Replaceable Units (CRUs) installed on the storage processors. You can use this information for servicing the CRUs. <br/> <br/>  
#>
Class UnitysvcCRU {

  #Properties

  [SvcCRUTypeEnum]$type #CRU type  
  [String]$serialNumber #CRU serial number.  
  [String]$partNumber #CRU part number.  

  #Methods

}

<#
  Name: UnitysvcStorageProcessor
  Description: Service-related information for the storage processors on the storage system. You can use this information for servicing the storage processors. There is always one svcStorageProcessor per SP in the system. <br/> <br/>  
#>
Class UnitysvcStorageProcessor {

  #Properties

  [SvcScopeEnum]$scope #Scope of the object  
  [Bool]$isServiceMode #Indicates whether the storage processor is in Service Mode. Values are: <ul> <li>true - SP is in Service Mode.</li> <li>false - SP is in Normal Mode.</li> </ul>  
  [Bool]$isPrimary #Indicates whether the storage processor is the primary SP. The primary SP is the storage processor on which the management stack runs. Values are: <ul> <li>true - SP is the primary SP. </li> <li>false - SP is not the primary SP. </li> </ul>  
  [String]$softwareVersion #Software version of the storage processor  
  [String]$hostName #Host name of the storage processor. This host name corresponds to control path IP on this SP.  
  [String]$serviceModeReason #Service mode reason (Rescue Reason Code), is a hexadecimal-formatted code. If the storage processor is in service mode, this code indicates why the SP is in Service Mode. <p> If the SP is in Normal Mode, the value of this attribute is null.  
  [String]$serviceModeReasonHint #Service mode reason hint (Rescue reason hint code), is a hexadecimal-formatted code. If the SP is in Service Mode, this code provides additional information as to why the SP is in Service Mode. <p> If the SP is in Normal Mode, the value of this attribute is null.  
  [String]$serviceModeRecommendedAction #Localized recommended action in service mode. If the storage processor is in service mode, this message indicates the recommended action the user can take to get the storage processor out of service mode. <p> If the SP is in Normal Mode, the value of this attribute is null.  
  [String]$status #Localized storage processor status message.  
  [Object[]]$crus #Customer Replaceable Units (CRUs) that are installed on the storage processor. Usually, there is at least one Solid State Disk (SSD) and one or more SLICs.  

  #Methods

}

<#
  Name: UnitysystemCapacity
  Description: Capacity data for all pools collected for the storage system.  
#>
Class UnitysystemCapacity {

  #Properties

  [String]$id #Unique identifier of the systemCapacity instance.  
  [Object]$sizeFree #Amount of free space available in the pools on the storage system.  
  [Object]$sizeTotal #Total amount of space (used space plus free space) in the pools on the storage system.  
  [Object]$sizeUsed #Amount of used space in the pools on the storage system.  
  [Object]$compressionSizeSaved #Amount of space saved by compression in the pools on the storage system.  
  [Object]$compressionPercent #Compression enabled increase of storage space expressed as percentage of summary of used and compression saved space size.  
  [Float]$compressionRatio #compression ratio  
  [Object]$sizeSubscribed #Size of space requested by the storage resources allocated in all pools for possible future allocations. If this value is greater than the total size, it means pools are oversubscribed.  
  [Object[]]$tiers #Size information (total, free, used) per tier.  

  #Methods

}

<#
  Name: UnitysystemInformation
  Description: Contact information for storage system.  
#>
Class UnitysystemInformation {

  #Properties

  [String]$id #Unique identifier of the systemInformation instance.  
  [String]$contactFirstName #Contact first name for the storage system.  
  [String]$contactLastName #Contact last name for the storage system.  
  [String]$contactCompany #Contact company name for the storage system.  
  [String]$contactPhone #Phone number for the person who should be contacted by the service provider for service issues.  
  [String]$contactEmail #Contact email address for the storage system.  
  [String]$locationName #The physical location of this system within the user's environment. For example: Building C, lab 5, tile C25  
  [String]$streetAddress #Street address for the storage system.  
  [String]$city #City where the storage system resides.  
  [String]$state #State where the storage system resides.  
  [String]$zipcode #Zip code or postal code where the storage system resides. --eng Zip Code is not currently supported by the ESRS VE system information api  
  [String]$country #Country where the storage system resides.  
  [String]$siteId #The ID identifying the site where this system is installed.  
  [String]$contactMobilePhone #Mobile phone number for the person who should be contacted by the service provider for service issues.  

  #Methods

}

<#
  Name: UnitysystemLimit
  Description: Information about system limits.  
#>
Class UnitysystemLimit {

  #Properties

  [String]$id #Unique identifier of the systemLimit instance.  
  [String]$name #Limit name.  
  [String]$description #Limit description.  
  [UnitEnum]$unit #Units of measurement for limit and threshold values.  
  [Object]$limitValue #Boundary value that cannot be exceeded.  
  [Object]$thresholdValue #Value at which the system generates alert notifications, if any.  
  [String[]]$resources #Resource types to which the limit applies.  
  [Object]$license #License on which the limit depends, if any, as defined by the license resource type.  

  #Methods

}

<#
  Name: UnitysystemTierCapacity
  Description: Capacity data for one tier, collected from all pools.  
#>
Class UnitysystemTierCapacity {

  #Properties

  [TierTypeEnum]$tierType #Tier type.  
  [Object]$sizeFree #Amount of free space available in the tier.  
  [Object]$sizeTotal #Total amount of space (used space plus free space) in the tier.  
  [Object]$sizeUsed #Amount of space used by the tier's associated storage resources.  

  #Methods

}

<#
  Name: UnitysystemTime
  Description: Current system time.  
#>
Class UnitysystemTime {

  #Properties

  [String]$id #Unique identifier of the systemTime instance. Because systemTime is a singleton resource type, the value of this field is always 0.  
  [DateTime]$time #Current system time.  

  #Methods

}

<#
  Name: UnitytechnicalAdvisory
  Description: Information about the Technical Advisories provided by EMC Support.  
#>
Class UnitytechnicalAdvisory {

  #Properties

  [String]$id #Unique identifier of the technicalAdvisory instance.  
  [String]$knowledgeBaseId #Knowledgebase number for the Technical Advisory.  
  [String]$description #Description of the Technical Advisory.  
  [DateTime]$modificationTime #Latest publication date for the Technical Advisory.  

  #Methods

}

<#
  Name: Unitytenant
  Description: A tenant is a representation of a datacenter client, who uses an independent network structure and gets the independent and exclusive access to certain storage resources. On the storage array, it corresponds to a NAS server group with an independent IP addressing. At the moment, iSCSI and management resources do not support multi-tenant access. For each tenant a corresponding Linux network namespace is created. In the current design, traffic separation between the tenants is done by the VLANs. Each tenant reserves a group of VLANs, and each VLAN can belong to one tenant maximum. Every tenant gets a name and the Universally Unique Identifier (UUID). The UUID cannot be changed during the tenant life cycle. The asynchronous replication of the NAS servers is allowed only between the servers belonging to the tenants with the same UUID. The NAS servers and VLANs can still belong to no tenant. Such NAS servers and VLANs operate in the Linux base network namespace, together with management and iSCSI interfaces. The control stack of the system does not allow user to log in in the tenant administrator role. All the tenants, NAS servers and VLANs are managed from the single system administrator account. To allow this, the corresponding GUI and CLI modifications are made.  
#>
Class Unitytenant {

  #Properties

  [String]$id #Unique identifier of the tenant instance.  
  [String]$name #User-specified name of the tenant.  
  [String]$uuid #UUID of the tenant.  
  [Object[]]$vlans #VLAN IDs assigned to the tenant.  
  [Object[]]$hosts #The hosts associated with the current tenant

  #Methods

}

<#
  Name: UnitytracerouteResult
  Description: Information about traceroute command result.  
#>
Class UnitytracerouteResult {

  #Properties

  [Object]$hop #Hop number.  
  [Object]$ipAddress #IP Address  
  [Float]$latency #Latency in milliseconds  
  [Bool]$result #True if accessible, False otherwise.  
  [String]$raw #Raw string output.  

  #Methods

}

<#
  Name: UnitytreeQuota
  Description: A treeQuota instance represents a quota limit applied to a specific directory tree in a file system.  
#>
Class UnitytreeQuota {

  #Properties

  [String]$id #Unique identifier of the tree quota instance.  
  [Object]$filesystem #Associated file system.  
  [Object]$quotaConfig #Associated quotaConfig instance.  
  [String]$path #Path relative to the root of the filesystem.  
  [String]$description #Description of the tree quota.  
  [QuotaStateEnum]$state #State of the tree quota.  
  [Object]$hardLimit #Hard limit.  
  [Object]$softLimit #Soft limit.  
  [Object]$remainingGracePeriod #The remaining grace period, when the soft limit is exceeded. <br> The value 0 means the grace period has been past.  
  [Object]$sizeUsed #The size already used.  

  #Methods

}

<#
  Name: UnityupgradeMessage
  Description: A message occurrence. This is also the message object returned in the body of non-2xx return code REST responses.  
#>
Class UnityupgradeMessage {

  #Properties

  [Object[]]$messages #List of localized messages.  
  [String]$errorCode #Error code for this message.  
  [SeverityEnum]$severity #Severity level associated with this message.  
  [Object]$httpStatus #HTTP status code for this message.  

  #Methods

}

<#
  Name: UnityupgradeSession
  Description: Information about a storage system upgrade session. <br/> <br/> Create or view an upgrade session to upgrade the system software or hardware. <br/> <br/> A hardware upgrade session starts or shows the status of a hardware upgrade. <br/> <br/> A software upgrade session installs an upgrade candidate file that was uploaded to the system. Download the latest upgrade candidate from EMC Online Support website. Use the CLI to upload the upgrade candidate to the system before creating the upgrade session. For information, see the <i>Unisphere CLI User Guide</i>. <br/> <br/> The latest software upgrade candidate contains all available hot fixes. If you have applied hot fixes to your system, the hot fixes are included in the latest upgrade candidate. <br/> <br/> <b>Note: </b>All system components must be healthy prior to upgrading the system software. If any system components are degraded, the software update will fail.  
#>
Class UnityupgradeSession {

  #Properties

  [String]$id #Unique identifier for the upgradeSession instance.  
  [UpgradeSessionTypeEnum]$type #Type of software or hardware upgrade.  
  [Object]$candidate #Candidate software to install in the upgrade session, as defined by the candidateSoftwareVersion resource type. This value does not exist for a hardware upgrade session.  
  [String]$caption #Caption for this upgrade session.  
  [UpgradeStatusEnum]$status #Status of the current upgrade session.  
  [Object[]]$messages # 
  [DateTime]$creationTime #Date and time when the upgrade session was started.  
  [DateTime]$elapsedTime #Amount of time for which the upgrade session was running.  
  [Object]$percentComplete #Percentage of the upgrade that is completed.  
  [Object[]]$tasks #Current upgrade activity in the upgrade session, as defined by the upgradeTask resource type.  

  #Methods

}

<#
  Name: UnityupgradeTask
  Description: Information about the upgrade task currently in progress.  
#>
Class UnityupgradeTask {

  #Properties

  [String]$caption #Caption for this task.  
  [DateTime]$creationTime #Date and time when the upgrade task was started.  
  [UpgradeStatusEnum]$status #Current status of the upgrade activity.  
  [UpgradeSessionTypeEnum]$type #Upgrade session type.  
  [DateTime]$estRemainTime #Estimated time remaining for the upgrade task.  

  #Methods

}

<#
  Name: UnityurServer
  Description: Information for registering a storage system with Unisphere Central.  
#>
Class UnityurServer {

  #Properties

  [Object]$address #IP address of the Unisphere Central server.  
  [String]$id #Unique identifier of the urServer instance. This value is always 0, because the object is a singleton.  

  #Methods

}

<#
  Name: UnityuserQuota
  Description: A userQuota instance represents a quota limit applied to a user within a quota tree or a file system.  
#>
Class UnityuserQuota {

  #Properties

  [String]$id #Unique identifier of the user quota instance.  
  [Object]$filesystem #Associated file system.  
  [Object]$treeQuota #Associated tree quota. Values are: <ul> <li> null - if the user quota is not within a quota tree. </li> <li> treeQuota instance - if the user quota is within a quota tree. </li> </ul>  
  [Object]$uid #User ID of the user.  
  [QuotaStateEnum]$state #State of the user quota.  
  [Object]$hardLimit #Hard limit. <br> The value 0 means no limitations.  
  [Object]$softLimit #Soft limit. <br> The value 0 means no limitations.  
  [Object]$remainingGracePeriod #Remaining grace period when the soft limit is exceeded. <br> The grace period of userQuota is set in quotaConfig.  
  [Object]$sizeUsed #Size already used by the user.  

  #Methods

}

<#
  Name: UnityvirtualDisk
  Description: Information about the external virtual disks that can be used as storage resources in a storage pool. <br/>  
#>
Class UnityvirtualDisk {

  #Properties

  [String]$id #Unique identifier of the virtualDisk instance.  
  [PoolUnitTypeEnum]$type #Pool unit type. This value is always Virtual_Disk(2).  
  [UnityHealth]$health #Health information for the virtual disk, as defined by the health resource type.  
  [String]$name #Virtual disk name.  
  [String]$wwn #World Wide Name (WWN) of the virtual disk.  
  [String]$spaScsiId #SPA SCSI ID of the virtual disk, as assigned by the VM to which the disk is attached.  
  [Object]$rawSize #Raw (unformatted) capacity of the virtual disk.  
  [Object]$sizeTotal #Usable capacity of the virtual disk.  
  [TierTypeEnum]$tierType #Virtual disk tier type.  
  [Object]$pool #Pool to which the virtual disk belongs, as defined by the pool resource type.  
  [Bool]$isInUse #Indicates whether the virtual disk is in use. The virtual disk is in use when it's consumed by a storage pool or being added to a storage pool. <ul> <li>true - Virtual disk is in use.</li> <li>false - Virtual disk is not in use.</li> </ul>  
  [Object]$backingStore #The backingStore associated with the current virtualDisk

  #Methods

}

<#
  Name: UnityvirtualVolume
  Description: VASA 2.0 virtual volume (VVol).  
#>
Class UnityvirtualVolume {

  #Properties

  [String]$id #Unique identifier of the VVol.  
  [UnityHealth]$health #Health information for the virtual volume.  
  [String]$name #Virtual volume name.  
  [VVolTypeEnum]$vvolType #Type of the VVol.  
  [ReplicaTypeEnum]$replicaType #Replica type of the VVol.  
  [Object]$parent #For non-base VVols, the parent VVol.  
  [Object]$storageResource #The datastore-type storage resource in which the VVol is provisioned.  
  [Object]$pool #Pool associated with the VVol.  
  [Object]$capabilityProfile #Capability profile associated with this VVol.  
  [String]$policyProfileName #The name of the VASA Policy Profile that vSphere has associated with this virtual volume.  
  [Bool]$isCompliant #Indicates whether the is VVol compliant with associated policy profile. true - VVol is compliant. false - VVol is not compliant.  
  [Bool]$isThinEnabled #True if thin provisioning is enabled.  
  [Object]$sizeTotal #Logical or addressable size of the object.  
  [Object]$sizeUsed #The amount of space used by the object from the pool.  
  [Object[]]$bindings #List of virtualVolumeBinding objects which contain binding information. Empty if virtual volume is not bound.  
  [String]$vmUUID #VMware UUID of the hosted virtual machine. Helps to identify virtual machine if VMware integration is not set.  
  [Object]$vm #Reference to the virtual machine hosted on the virtual volume. Always empty if VMware integration not configured.  
  [Object]$vmDisk #Reference to associated virual machine disk object. Always empty if VMware integration not configured.  

  #Methods

}

<#
  Name: UnityvirtualVolumeBinding
  Description: VASA 2.0 VVol bindings, showing the connection between the VVol on the storage array and the VMware protocol endpoint.  
#>
Class UnityvirtualVolumeBinding {

  #Properties

  [Object]$vmwarePE #VMware protocol endpoint to which the VVol is bound.  
  [String]$bindingDetails #Export path for Virtual Volumes bound with NFS. Secondary SCSI ID for Virtual Volumes bound with iSCSI.  

  #Methods

}

<#
  Name: UnityvirusChecker
  Description: Information about the anti-virus service of a NAS server. <br/> <br/> The storage system supports third-party anti-virus servers that perform virus scans and reports back to the storage system. For example, when an SMB client creates, moves, or modifies a file, the NAS server invokes the anti-virus server to scan the file for known viruses. During the scan any access to this file is blocked. If the file does not contain a virus, it is written to the file system. If the file is infected, corrective action (fixed, removed or placed in quarantine) is taken as defined by the anti-virus server. You can optionally set up the service to scan the file on read access based on last access of the file compared to last update of the third-party anti-virus date. <br/> A virusChecker object is created each time the anti-virus service is enabled on a NAS server. A configuration file (named viruschecker.conf) needs to be uploaded on the NAS server before enabling the anti-virus service.  
#>
Class UnityvirusChecker {

  #Properties

  [String]$id #Unique instance id.  
  [Object]$nasServer #NAS server that is configured with these anti-virus settings.  
  [Bool]$isEnabled #Indicates whether the anti-virus service is enabled on this NAS server. Value are: <ul> <li>true - Anti-virus service is enabled. Each file created or modified by an SMB client is scanned by the third-party anti-virus servers. If a virus is detected, the access to the file system is denied. If third-party anti-virus servers are not available, according the policy, the access to the file systems is denied to prevent potential viruses propagation.</li> <li>false - Anti-virus service is disabled. File systems of the NAS servers are available for access without virus checking</li> </ul>  

  #Methods

}

<#
  Name: UnityvlanInfo
  Description: Information about VLAN IDs.  
#>
Class UnityvlanInfo {

  #Properties

  [String]$id #Unique identifier of the vlanInfo instance.  
  [Object]$vlanId #VLAN ID.  
  [Object[]]$interfaces #List of IP interfaces created on this VLAN.  
  [Object]$tenant #Tenant to which the VLAN belongs.  

  #Methods

}

<#
  Name: Unityvm
  Description: Represents a virtual machine.  
#>
Class Unityvm {

  #Properties

  [String]$id #Unique instance id.  
  [Object]$datastore #The storageResource that hosts configuration data of the VM.  
  [String]$name #Friendly name of VM displayed on vCenter.  
  [Object[]]$guestAddresses #The guest addresses of VM. Can be IPv4, IPv6, or both.  
  [String]$guestHostName #The host name of VM guest host.  
  [String]$notes #Notes for VM.  
  [String]$osType #The OS type of VM.  
  [Object]$host #ESXi host that hosts VM.  
  [VMPowerStateEnum]$state #The state of VM.  
  [Object[]]$virtualVolumes #The virtualVolumes associated with the current vm
  [Object[]]$vmDisks #The vmDisks associated with the current vm

  #Methods

}

<#
  Name: UnityvmDisk
  Description: Virtual Machine disk object.  
#>
Class UnityvmDisk {

  #Properties

  [Object]$datastore #The datastore that hosts the VM disk.  
  [String]$id #Unique instance ID.  
  [Object]$vm #The associated VM.  
  [String]$name #Friendly name of VM disk displayed on vCenter.  
  [Object]$spaceTotal #Size of the VM disk.  
  [VMDiskTypeEnum]$type #Type of the VM disk.  
  [Object]$virtualVolumes #The virtualVolume associated with the current vmDisk

  #Methods

}

<#
  Name: UnityvmwareIscsiParameters
  Description: Settings for an iSCSI LUN used as a VMWare VMFS datastore. <br/> <br/> This resource type is embedded in the storageResource resource type.  
#>
Class UnityvmwareIscsiParameters {

  #Properties

  [ESXFilesystemMajorVersionEnum]$majorVersion #VMFS major version.  
  [ESXFilesystemBlockSizeEnum]$blockSize #VMFS block size.  

  #Methods

}

<#
  Name: UnityvmwareNasPEServer
  Description: A resource representing NAS VMware Protocol Endpoint Server. Only one instance per NAS Server can be created.  
#>
Class UnityvmwareNasPEServer {

  #Properties

  [String]$id #Unique identifier of NAS VMware Protocol Endpoint Server.  
  [Object]$nasServer #NAS server for this protocol endpoint.  
  [Object[]]$fileInterfaces #A list of file IP interfaces to be used by NAS VMware Protocol Endpoint Server.  
  [Object]$boundVVolCount #The number of bound VVols associated with NAS VMware Protocol Endpoint Server.  

  #Methods

}

<#
  Name: UnityvmwarePE
  Description: A resource representing VMware protocol endpoint of both possible types: NAS protocol endpoint and SCSI protocol endpoint. An instance of this class is created automatically as part of VVol datastore (storage resource) host access configuration.  
#>
Class UnityvmwarePE {

  #Properties

  [String]$id #Unique identifier of VMware protocol endpoint.  
  [Object]$vmwareNasPEServer #For NAS VMware protocol endpoints, the associated NAS VMware protocol endpoint server.  
  [String]$name #VMware protocol endpoint name.  
  [VmwarePETypeEnum]$type #Protocol Endpoint type.  
  [String]$vmwareUUID #VMware UUID for this protocol endpoint.  
  [String]$exportPath #For NAS VMware protocol endpoints, the export path.  
  [Object]$ipAddress #For NAS VMware protocol endpoints, the IP address.  
  [IpProtocolVersionEnum]$ipProtocolVersion #For NAS VMware protocol endpoints, IP protocol version (IPv4 or IPv6).  
  [NodeEnum]$defaultNode #For SCSI VMware protocol endpoints, the default owning SP.  
  [NodeEnum]$currentNode #For SCSI VMware protocol endpoints, the current SP.  
  [String]$wwn #WWN for SCSI VMware protocol endpoints.  
  [String]$naa #For SCSI VMware protocol endpoints, the VMware protocol endpoint SCSI identifier in naa format.  
  [Object]$vvolds #For NAS protocol endpoints, the associated datastore type storage resource.  
  [Object]$host #For SCSI VMware protocol endpoints, the unique identifier of associated host.  
  [Object]$lunId #For SCSI VMware protocol endpoints, the identifier of assiciated LUN.  
  [Object]$boundVVolCount #The number of bound VVols associated with NAS VMware Protocol Endpoint.  
  [UnityHealth]$health #Health information for the VMware Protocol Endpoint.  

  #Methods

}

<#
  Name: UnityvvolDatastoreCapabilityProfilesParameters
  Description: Capability profile parameters used for creation/modification of a VVol Datastore. <br/> <br/> This resource type is embedded in the storageResource resource type.  
#>
Class UnityvvolDatastoreCapabilityProfilesParameters {

  #Properties

  [Object[]]$addCapabilityProfile #CapabilityProfiles to add to the VVol datastore, as defined by the VVol Datastore resource type.  
  [Object[]]$modifyCapabilityProfile #CapabilityProfiles, used by the VVol Datastore, support of that should be modified.  
  [Object[]]$removeCapabilityProfile #CapabilityProfiles to remove from the VVol datastore, as defined by the VVol Datastore resource type.  

  #Methods

}

<#
  Name: Unityx509Certificate
  Description: Information about the X.509 certificates installed on the storage system. The X.509 certificate format is described in RFC 5280.  
#>
Class Unityx509Certificate {

  #Properties

  [String]$id #Unique identifier of the x509Certificate instance.  
  [CertificateTypeEnum]$type #Certificate type.  
  [ServiceTypeEnum]$service #Service with which the certificate is associated.  
  [Object]$scope #Scope of the certificate.  
  [Bool]$isTrustAnchor #Indicates whether the certificate is trusted as end-of-chain for peer certificate verification. This applies to certificates with a type of CA only. Values are: <ul> <li>true - Certificate is trusted. It is either permanent, or the expiration date has not yet passed.</li> <li>false - Certificate is not trusted.</li> </ul>  
  [Object]$version #Certificate version.  
  [String]$serialNumber #Certificate serial number.  
  [SignatureAlgoTypeEnum]$signatureAlgorithm #Certificate signature algorithm.  
  [String]$issuer #Name of the certificate issuer.  
  [DateTime]$validFrom #Date and time when the certificate became valid.  
  [DateTime]$validTo #Date and time when the certificate will expire.  
  [String]$subject #Certificate subject.  
  [String]$subjectAlternativeName #Certificate subject alternative name.  
  [PublicKeyAlgoTypeEnum]$publicKeyAlgorithm #Certificate public key algorithm.  
  [Object]$keyLength #Certificate key length.  
  [ThumbprintAlgoTypeEnum]$thumbprintAlgorithm #Certificate thumbprint algorithm.  
  [String]$thumbprint #Certificate thumbprint.  
  [Bool]$hasPrivateKey #Indicates whether the certificate has an associated private key. Values are: <ul> <li>true - Certificate has an associated private key. </li> <li>false - Certificate does not have an associated private key. </li> </ul>  

  #Methods

}







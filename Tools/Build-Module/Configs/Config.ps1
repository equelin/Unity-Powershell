# Initializing empty array
$cfg = @{}

# Project root folder
$cfg.ProjectRoot = 'F:\Code\GitHub\Unity-Powershell'

$Cfg.FormatOutputPath = 'F:\Code\GitHub\Unity-Powershell\Unity-Powershell\Format\'

$cfg.Classes = @(
    @{TypeName='UnityAlert'; TableHeaderList=@('id','Severity','Timestamp','MessageId','Message','IsAcknowledged')}
    @{TypeName='UnityDae'; TableHeaderList=@('id','name','busId','slotNumber','model')}
    @{TypeName='UnityDisk'; TableHeaderList=@('id','name','Rawsize','DiskTechnology','Rpm','Bankslot')}
    @{TypeName='UnityDpe'; TableHeaderList=@('id','name','busId','slotNumber','model')}
    @{TypeName='UnityEncryption'; TableHeaderList=@('id','encryptionMode','encryptionStatus','encryptionPercentage','keyManagerBackupKeyStatus')}
    @{TypeName='UnityEthernetPort'; TableHeaderList=@('id','name','StorageProcessor','PortNumber','ConnectorType','Mtu','NeedsReplacement')}
    @{TypeName='UnitySsc'; TableHeaderList=@('id','name','parentDae','slotNumber','model')}
    @{TypeName='UnitySsd'; TableHeaderList=@('id','name','parent','slotNumber','model')}
    @{TypeName='UnityStorageProcessor'; TableHeaderList=@('id','name','parentDpe','slotNumber','model')}
    @{TypeName='Unityvm'; TableHeaderList=@('id','name','datastore','guestHostName','osType','state')}
    @{TypeName='Unitydatastore'; TableHeaderList=@('id','name','host','sizeTotal','sizeUsed')}
    @{TypeName='UnityinstalledSoftwareVersion'; TableHeaderList=@('id','version','revision','releaseDate')}
    @{TypeName='UnityfastVP'; TableHeaderList=@('id','status','relocationRate','isScheduleEnabled')}
    @{TypeName='UnityvmwareNasPEServer'; TableHeaderList=@('id','nasServer','fileInterfaces','boundVVolCount')}
    @{TypeName='UnityvmwarePE'; TableHeaderList=@('id','name','vmwareNasPEServer','type')}
    @{TypeName='Unityx509Certificate'; TableHeaderList=@('id','type','service','scope','ValidTo')}
    @{TypeName='UnityserviceInfo'; TableHeaderList=@('id','productName','productSerialNumber','isSSHEnabled','esrsStatus')}
    @{TypeName='UnityserviceAction'; TableHeaderList=@('id','name','scope','isApplicable','applyCondition')}
    @{TypeName='UnitylinkAggregation'; TableHeaderList=@('id','name','shortName','masterPort','isLinkUp')}
    @{TypeName='UnitydataCollectionResult'; TableHeaderList=@('id','name','creationTime','profile')}
    @{TypeName='UnityfcPort'; TableHeaderList=@('id','name','slotNumber','wwn','currentSpeed','portRepCapabilities')}
    @{TypeName='Unitybattery'; TableHeaderList=@('id','name','slotNumber','emcSerialNumber','emcPartNumber','firmwareVersion')}
    @{TypeName='UnityPool'; TableHeaderList=@('id','name','SizeFree','SizeTotal','SizeUsed','SizeSubscribed','IsFASTCacheEnabled','Type','RaidType')}
    @{TypeName='UnitySystem'; TableHeaderList=@('id','name','Model','SerialNumber','Platform','MacAddress')}
)




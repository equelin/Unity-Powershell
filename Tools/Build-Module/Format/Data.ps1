$Data = @{}

$Data.Class = @(
    @{TypeName='UnityDae'; TableHeaderList=@('id','name','busId','slotNumber','model')}
    @{TypeName='UnityDisk'; TableHeaderList=@('id','name','Rawsize','DiskTechnology','Rpm','Bankslot')}
    @{TypeName='UnityDpe'; TableHeaderList=@('id','name','busId','slotNumber','model')}
    @{TypeName='UnityEncryption'; TableHeaderList=@('id','encryptionMode','encryptionStatus','encryptionPercentage','keyManagerBackupKeyStatus')}
    @{TypeName='UnityEthernetPort'; TableHeaderList=@('id','name','StorageProcessor','PortNumber','ConnectorType','Mtu','NeedsReplacement')}
    @{TypeName='UnitySsc'; TableHeaderList=@('id','name','parentDae','slotNumber','model')}
    @{TypeName='UnitySsd'; TableHeaderList=@('id','name','parent','slotNumber','model')}
    @{TypeName='UnityStorageProcessor'; TableHeaderList=@('id','name','parentDpe','slotNumber','model')}
    @{TypeName='Unityvm'; TableHeaderList=@('id','name','datastore','guestHostName','osType','state')}
)


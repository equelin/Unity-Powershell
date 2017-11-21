# New-UnitySnap

## SYNOPSIS
Creates a new snapshot.

## SYNTAX

```
New-UnitySnap [[-session] <Object>] [-storageResource] <Object[]> [[-name] <String>] [[-Description] <String>]
 [[-isAutoDelete] <Boolean>] [[-retentionDuration] <UInt64>] [[-isReadOnly] <Boolean>]
 [[-filesystemAccessType] <FilesystemSnapAccessTypeEnum>] [-WhatIf] [-Confirm]
```

## DESCRIPTION
Creates a new snapshot.
Creating a snapshot creates a new point-in-time view of a block or file resource associated with the point-in-time at which the snapshot was taken. 
Immediately after being created, a snapshot consumes almost no space for the pool as it still shares all of its blocks with the primary block or file resource.
However as new data is written to the parent resource, redirects occur as discussed previously, and the snapshot begins to consume pool space that is not also associated with the current production version of the parent resource. 
Once a snapshot is created, it is available to perform snapshot operations on such as restoring, copying, attaching/detaching, or deleting.
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
New-UnitySnap -StorageResource 'res_41' -Name 'snap01'
```

Create snap named 'snap01' from sorage resource ID 'res_41'

### -------------------------- EXAMPLE 2 --------------------------
```
Get-UnityVMwareNFS -Name 'VOLUME01' | New-UnitySnap
```

Create a snapshot of the VMware NFS volume.

## PARAMETERS

### -session
Specify an UnitySession Object.

```yaml
Type: Object
Parameter Sets: (All)
Aliases: 

Required: False
Position: 1
Default value: ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true})
Accept pipeline input: False
Accept wildcard characters: False
```

### -storageResource
UnitySnap

```yaml
Type: Object[]
Parameter Sets: (All)
Aliases: 

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -name
Name for the new snapshot.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Description
Description for new snapshot.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -isAutoDelete
Auto delete policy for new snapshot.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases: 

Required: False
Position: 5
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -retentionDuration
How long (in seconds) to keep the snapshot (Can be specified only if auto delete is set to false).

```yaml
Type: UInt64
Parameter Sets: (All)
Aliases: 

Required: False
Position: 6
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -isReadOnly
Indicates if the new snapshot should be read-only.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases: 

Required: False
Position: 7
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -filesystemAccessType
Indicates if the new snapshot should be created with checkpoint or protocol type access (file system or VMware NFS datastore snapshots only).

```yaml
Type: FilesystemSnapAccessTypeEnum
Parameter Sets: (All)
Aliases: 
Accepted values: Checkpoint, Protocol

Required: False
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Indicate that the cmdlet is run only to display the changes that would be made and actually no objects are modified.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
If the value is $true, indicates that the cmdlet asks for confirmation before running.
If the value is $false, the cmdlet runs without asking for user confirmation.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES
Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE

## RELATED LINKS

[https://github.com/equelin/Unity-Powershell](https://github.com/equelin/Unity-Powershell)


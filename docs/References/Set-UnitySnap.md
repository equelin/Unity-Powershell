# Set-UnitySnap

## SYNOPSIS
Modifies snapshot parameters.

## SYNTAX

### Set (Default)
```
Set-UnitySnap [-session <Object>] [-ID] <Object[]> [-name <String[]>] [-Description <String>]
 [-isAutoDelete <Boolean>] [-retentionDuration <UInt64>] [-ioLimitParameters <String>] [-WhatIf] [-Confirm]
```

### Refresh
```
Set-UnitySnap [-session <Object>] [-ID] <Object[]> [-refresh] [-copyName <String>] [-WhatIf] [-Confirm]
```

### Detach
```
Set-UnitySnap [-session <Object>] [-ID] <Object[]> [-detach] [-WhatIf] [-Confirm]
```

### Attach
```
Set-UnitySnap [-session <Object>] [-ID] <Object[]> [-attach] [-copyName <String>] [-WhatIf] [-Confirm]
```

### Restore
```
Set-UnitySnap [-session <Object>] [-ID] <Object[]> [-restore] [-copyName <String>] [-WhatIf] [-Confirm]
```

### Copy
```
Set-UnitySnap [-session <Object>] [-ID] <Object[]> [-copy] [-numCopies <UInt32>] [-copyStartNum <UInt32>]
 [-copyName <String>] [-WhatIf] [-Confirm]
```

## DESCRIPTION
Modifies snapshot parameters.
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Set-UnitySnap -ID '171798691854' -Description 'Modified description'
```

Change the description of the snapshot with ID '171798691854'

### -------------------------- EXAMPLE 2 --------------------------
```
Set-UnitySnap -ID '171798691854' -Copy -numCopies 2
```

Copy 2 times the snapshot with ID '171798691854'

### -------------------------- EXAMPLE 3 --------------------------
```
Set-UnitySnap -ID '171798691854' -Restore
```

Restore the snapshot with ID '171798691854' to the associated storage resource.

### -------------------------- EXAMPLE 4 --------------------------
```
Set-UnitySnap -ID '171798691854' -Attach
```

Attach the snapshot with ID '171798691854' so hosts can access it.'

### -------------------------- EXAMPLE 5 --------------------------
```
Set-UnitySnap -ID '171798691854' -Detach
```

Detach the snapshot with ID '171798691854' so hosts can no longer access it.

### -------------------------- EXAMPLE 6 --------------------------
```
Set-UnitySnap -ID '171798691854' -Refresh
```

Refreshes snapshot with ID '171798691854' with the latest data from the parent LUN.

## PARAMETERS

### -session
Specify an UnitySession Object.

```yaml
Type: Object
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true})
Accept pipeline input: False
Accept wildcard characters: False
```

### -ID
Snapshot ID or Object.

```yaml
Type: Object[]
Parameter Sets: (All)
Aliases: 

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -name
Snapshot name (Applies to block type storage resource snaps only.
Filesystem snapshot names cannot be modified).

```yaml
Type: String[]
Parameter Sets: Set
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Description
Snapshot description.

```yaml
Type: String
Parameter Sets: Set
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -isAutoDelete
Indicates whether the system will automatically delete the snapshot when the pool snapshot space or total pool space reaches an automatic deletion threshold.

```yaml
Type: Boolean
Parameter Sets: Set
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -retentionDuration
How long (in seconds) to keep the snapshot (Can be specified only if auto delete is set to false).

```yaml
Type: UInt64
Parameter Sets: Set
Aliases: 

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -ioLimitParameters
The IO limit policy that is applied to this snapshot.
This is only applicable to attached snapshots.

```yaml
Type: String
Parameter Sets: Set
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -copy
Copy a snapshot.

```yaml
Type: SwitchParameter
Parameter Sets: Copy
Aliases: 

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -numCopies
Number of snapshot copies to make.

```yaml
Type: UInt32
Parameter Sets: Copy
Aliases: 

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -copyStartNum
Starting number for the group of copies.
This number gets appended to the name specified in the copyName argument to form the name of the first snapshot copy.
The system increments the number for each new snapshot.

```yaml
Type: UInt32
Parameter Sets: Copy
Aliases: 

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -restore
Restore the snapshot to the associated storage resource.

```yaml
Type: SwitchParameter
Parameter Sets: Restore
Aliases: 

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -attach
Attach the snapshot so hosts can access it.
Attaching a snapshot makes the snapshot accessible to configured hosts for restoring files and data.

```yaml
Type: SwitchParameter
Parameter Sets: Attach
Aliases: 

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -detach
Detach the snapshot so hosts can no longer access it.

```yaml
Type: SwitchParameter
Parameter Sets: Detach
Aliases: 

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -refresh
Refresh the snapshot to the associated storage resource.

```yaml
Type: SwitchParameter
Parameter Sets: Refresh
Aliases: 

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -copyName
Base name for the new snapshot copies or Name of the backup snapshot created before the restore/attach operation occurs.

```yaml
Type: String
Parameter Sets: Refresh, Attach, Restore, Copy
Aliases: 

Required: False
Position: Named
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


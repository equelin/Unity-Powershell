# Set-UnityPool

## SYNOPSIS
Modifies storage pool parameters.

## SYNTAX

### RaidGroup (Default)
```
Set-UnityPool [-session <Object>] [-ID] <Object[]> [-NewName <String>] [-Description <String>]
 [-AddraidGroup <Array>] [-alertThreshold <Int32>] [-poolSpaceHarvestHighThreshold <Int64>]
 [-poolSpaceHarvestLowThreshold <Int64>] [-snapSpaceHarvestHighThreshold <Int64>]
 [-snapSpaceHarvestLowThreshold <Int64>] [-isHarvestEnabled <Boolean>] [-isSnapHarvestEnabled <Boolean>]
 [-isFASTCacheEnabled <Boolean>] [-isFASTVpScheduleEnabled <Boolean>] [-WhatIf] [-Confirm]
```

### VirtualDisk
```
Set-UnityPool [-session <Object>] [-ID] <Object[]> [-NewName <String>] [-Description <String>]
 [-AddVirtualDisk <Array>] [-alertThreshold <Int32>] [-poolSpaceHarvestHighThreshold <Int64>]
 [-poolSpaceHarvestLowThreshold <Int64>] [-snapSpaceHarvestHighThreshold <Int64>]
 [-snapSpaceHarvestLowThreshold <Int64>] [-isHarvestEnabled <Boolean>] [-isSnapHarvestEnabled <Boolean>]
 [-isFASTCacheEnabled <Boolean>] [-isFASTVpScheduleEnabled <Boolean>] [-WhatIf] [-Confirm]
```

## DESCRIPTION
Modifies storage pool parameters.
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Set-UnityPool -ID 'pool_10' -Description 'Modified description'
```

Change the description of the pool with ID 'pool_10'

### -------------------------- EXAMPLE 2 --------------------------
```
Set-UnityPool -ID 'pool_10' -AddVirtualDisk @{'id'='vdisk_1';'tier'='Performance'}
```

Add a virtual disk 'vdisk_1' to the pool with ID 'pool_10'

### -------------------------- EXAMPLE 3 --------------------------
```
Set-UnityPool -ID 'pool_10' -AddraidGroup @{"id"='dg_8';"numDisks"= 8; 'raidType'='RAID6'; 'stripeWidth'='8'}
```

Add a raid group 'dg_8' to the pool with ID 'pool_10'

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
ID of the pool or Pool Object.

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

### -NewName
New name of the pool.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Description
Description of the pool.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AddVirtualDisk
Virtual Disks only with associated parameters to add to the pool.
See examples for details.

```yaml
Type: Array
Parameter Sets: VirtualDisk
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AddraidGroup
Parameters to add RAID groups to the pool (disk group, number of disks, RAID level, stripe length).
See examples for details.

```yaml
Type: Array
Parameter Sets: RaidGroup
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -alertThreshold
For thin provisioning, specify the threshold, as a percentage, when the system will alert on the amount of subscription space used.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -poolSpaceHarvestHighThreshold
Specify the pool full high watermark for the storage pool.

```yaml
Type: Int64
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -poolSpaceHarvestLowThreshold
Specify the pool full low watermark for the storage pool.

```yaml
Type: Int64
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -snapSpaceHarvestHighThreshold
Specify the snapshot space used high watermark to trigger auto-delete on the storage pool.

```yaml
Type: Int64
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -snapSpaceHarvestLowThreshold
Specify the snapshot space used low watermark to trigger auto-delete on the storage pool.

```yaml
Type: Int64
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -isHarvestEnabled
Indicate whether the system should check the pool full high water mark for autodelete.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -isSnapHarvestEnabled
Indicate whether the system should check the snapshot space used high water mark for auto-delete.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -isFASTCacheEnabled
Specify whether to enable FAST Cache on the storage pool.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -isFASTVpScheduleEnabled
Specify whether to enable scheduled data relocations for the pool.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
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


# New-UnityPool

## SYNOPSIS
Creates a new storage pool.

## SYNTAX

### RaidGroup (Default)
```
New-UnityPool [-session <Object>] [-Name] <String[]> [-Description <String>] -raidGroup <Array>
 [-alertThreshold <Int32>] [-poolSpaceHarvestHighThreshold <Int64>] [-poolSpaceHarvestLowThreshold <Int64>]
 [-snapSpaceHarvestHighThreshold <Int64>] [-snapSpaceHarvestLowThreshold <Int64>] [-isHarvestEnabled <Boolean>]
 [-isSnapHarvestEnabled <Boolean>] [-isFASTCacheEnabled <Boolean>] [-isFASTVpScheduleEnabled <Boolean>]
 [-Type <StoragePoolTypeEnum>] [-WhatIf] [-Confirm]
```

### VirtualDisk
```
New-UnityPool [-session <Object>] [-Name] <String[]> [-Description <String>] -virtualDisk <Array>
 [-alertThreshold <Int32>] [-poolSpaceHarvestHighThreshold <Int64>] [-poolSpaceHarvestLowThreshold <Int64>]
 [-snapSpaceHarvestHighThreshold <Int64>] [-snapSpaceHarvestLowThreshold <Int64>] [-isHarvestEnabled <Boolean>]
 [-isSnapHarvestEnabled <Boolean>] [-isFASTCacheEnabled <Boolean>] [-isFASTVpScheduleEnabled <Boolean>]
 [-Type <StoragePoolTypeEnum>] [-WhatIf] [-Confirm]
```

## DESCRIPTION
Creates a new storage pool.
Storage pools are the groups of disks on which you create storage resources like LUN or filesystems.
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
New-UnityPool -Name 'POOL01' -virtualDisk @{"id"='vdisk_1';"tier"='Extreme_Performance'},@{"id"='vdisk_2';"tier"='Capacity'}
```

Create pool named 'POOL01' with virtual disks 'vdisk_1' and 'vdisk_2'.
Virtual disks are assigned to the Extreme Performance and Capacity tier.
Apply to Unity VSA only.

### -------------------------- EXAMPLE 2 --------------------------
```
New-UnityPool -Name 'POOL01' -raidGroup @{"id"='dg_11';"numDisks"= 15; 'raidType'='RAID5'; 'stripeWidth'='5'}
```

Create pool named 'POOL01' with with 15 disks from diskgroup ID 'dg_11'.RAID protection is a 'RAID5' with a stripe width of 5 (4+1).
Apply to physical deployment only.

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

### -Name
Name of the pool.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
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

### -virtualDisk
Virtual Disks only with associated parameters to add to the pool.
See examples for details.

```yaml
Type: Array
Parameter Sets: VirtualDisk
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -raidGroup
Parameters to add RAID groups to the pool (disk group, number of disks, RAID level, stripe length).
See examples for details.

```yaml
Type: Array
Parameter Sets: RaidGroup
Aliases: 

Required: True
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

### -Type
Indicates whether to create traditional pool or dynamic pool.

```yaml
Type: StoragePoolTypeEnum
Parameter Sets: (All)
Aliases: 
Accepted values: Traditional, Dynamic

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


---
external help file: Unity-Powershell-help.xml
online version: https://github.com/equelin/Unity-Powershell
schema: 2.0.0
---

# Set-UnityVMwareLUN

## SYNOPSIS
Modifies VMware block LUN parameters.

## SYNTAX

```
Set-UnityVMwareLUN [-session <Object>] [-ID] <Object[]> [-Name <String>] [-Description <String>]
 [-Size <UInt64>] [-fastVPParameters <TieringPolicyEnum>] [-snapSchedule <String>]
 [-isSnapSchedulePaused <Boolean>] [-host <String[]>] [-append] [-accessMask <HostLUNAccessEnum>] [-WhatIf]
 [-Confirm]
```

## DESCRIPTION
Modifies VMware block LUN parameters.
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXEMPLE 1 --------------------------
```
Set-UnityVMwareLUN -ID 'sv_78' -Description 'Modified description'
```

Change the description of the VMware bock LUN with ID 'sv_78'.

### -------------------------- EXEMPLE 2 --------------------------
```
Set-UnityVMwareLUN -ID 'sv_78' -Pool 'pool_14' -host 'Host_12' -accessMask 'Production' -Append
```

Grant 'production' access to host 'Host_12' to VMware bock LUN with ID 'sv_78'.

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
ID or Object.

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

### -Name
New name of the VMware VMFS datastore unique to the system.

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
New description of the VMware VMFS datastore.

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

### -Size
New LUN size.
The size parameter can be greater than the current LUN size in this case the LUN is expanded.

```yaml
Type: UInt64
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -fastVPParameters
FAST VP settings for the storage resource

```yaml
Type: TieringPolicyEnum
Parameter Sets: (All)
Aliases: 
Accepted values: Autotier_High, Autotier, Highest, Lowest, No_Data_Movement, Mixed

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -snapSchedule
Snapshot schedule settings for the VMware VMFS datastore, as defined by the snapScheduleParameters.

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

### -isSnapSchedulePaused
Indicates whether the assigned snapshot schedule is paused.

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

### -host
List of host to grant access to LUN.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -append
Add new host access to the existing configuration.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -accessMask
Host access mask.
Might be:
- NoAccess: No access. 
- Production: Access to production LUNs only. 
- Snapshot: Access to LUN snapshots only. 
- Both: Access to both production LUNs and their snapshots.

```yaml
Type: HostLUNAccessEnum
Parameter Sets: (All)
Aliases: 
Accepted values: NoAccess, Production, Snapshot, Both, Mixed

Required: False
Position: Named
Default value: Production
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


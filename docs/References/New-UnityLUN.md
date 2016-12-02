---
external help file: Unity-Powershell-help.xml
online version: https://github.com/equelin/Unity-Powershell
schema: 2.0.0
---

# New-UnityLUN

## SYNOPSIS
Creates a Unity block LUN.

## SYNTAX

```
New-UnityLUN [-session <Object>] [-Name] <String[]> [-Description <String>] -Pool <String> -Size <UInt64>
 [-host <String[]>] [-accessMask <HostLUNAccessEnum>] [-isThinEnabled <Boolean>] [-snapSchedule <String>]
 [-isSnapSchedulePaused <Boolean>] [-WhatIf] [-Confirm]
```

## DESCRIPTION
Creates a Unity block LUN.
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXEMPLE 1 --------------------------
```
New-UnityLUN -Name 'DATASTORE01' -Pool 'pool_1' -Size 10GB -host 'Host_12' -accessMask 'Production'
```

Create LUN named 'LUN01' on pool 'pool_1' and with a size of '10GB', grant production access to 'Host_12'

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
Name of the LUN unique to the system.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Description
Description of the LUN.

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

### -Pool
Pool ID

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Size
LUN Size.

```yaml
Type: UInt64
Parameter Sets: (All)
Aliases: 

Required: True
Position: Named
Default value: 0
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

### -isThinEnabled
Is Thin enabled on LUN ?
(Default is true)

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: True
Accept pipeline input: False
Accept wildcard characters: False
```

### -snapSchedule
Snapshot schedule settings for the LUN, as defined by the snapScheduleParameters.

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


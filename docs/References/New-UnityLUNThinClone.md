# New-UnityLUNThinClone

## SYNOPSIS
Creates a LUN thin clone.

## SYNTAX

```
New-UnityLUNThinClone [[-session] <Object>] [-LUN] <Object> [-snap] <Object> [-name] <String>
 [[-Description] <String>] [[-ioLimitPolicy] <Object>] [[-host] <String[]>] [[-accessMask] <HostLUNAccessEnum>]
 [[-snapSchedule] <String>] [[-isSnapSchedulePaused] <Boolean>] [-WhatIf] [-Confirm]
```

## DESCRIPTION
Creates a LUN thin clone.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
$Snap = Get-UnityLUN -Name 'LUN01' | New-UnitySnap -isAutoDelete:$false
```

New-UnityLUNThinClone -LUN sv_79 -snap $snap.id -name 'LUN01-Thinclone' -snapSchedule 'snapSch_1' -host 'Host_36','Host_37'

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

### -LUN
LUN id

```yaml
Type: Object
Parameter Sets: (All)
Aliases: 

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -snap
The reference to the source snapshot ID object.

```yaml
Type: Object
Parameter Sets: (All)
Aliases: 

Required: True
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -name
Name for the new Thin Clone, unique to the system.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Description
Description of the Thin clone.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ioLimitPolicy
lunParameters

```yaml
Type: Object
Parameter Sets: (All)
Aliases: 

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -host
List of host to grant access to the thin clone.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 

Required: False
Position: 7
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
Position: 8
Default value: Production
Accept pipeline input: False
Accept wildcard characters: False
```

### -snapSchedule
Snapshot schedule assigned to the thin clone

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 9
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
Position: 10
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


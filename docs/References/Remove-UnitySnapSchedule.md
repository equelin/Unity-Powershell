---
external help file: Unity-Powershell-help.xml
online version: https://github.com/equelin/Unity-Powershell
schema: 2.0.0
---

# Remove-UnitySnapSchedule

## SYNOPSIS
Delete a snapshot schedule.

## SYNTAX

```
Remove-UnitySnapSchedule [-session <UnitySession[]>] [-ID] <Object[]> [-WhatIf] [-Confirm]
```

## DESCRIPTION
Delete a snapshot schedule.
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXEMPLE 1 --------------------------
```
Remove-UnitySnapSchedule -ID 'snapSch_11'
```

Delete the snapshot schedule with ID 'snapSch_11'

### -------------------------- EXEMPLE 2 --------------------------
```
Get-UnitySnapSchedule | Remove-UnitySnapSchedule
```

Delete all existing snapshots schedule.

## PARAMETERS

### -session
Specify an UnitySession Object.

```yaml
Type: UnitySession[]
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true})
Accept pipeline input: False
Accept wildcard characters: False
```

### -ID
ID of the snapshot Schedule or snapshot Schedule Object.

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


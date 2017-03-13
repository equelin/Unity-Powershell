---
external help file: Unity-Powershell-help.xml
online version: https://github.com/equelin/Unity-Powershell
schema: 2.0.0
---

# Update-UnityvCenter

## SYNOPSIS
Refresh vCenter hosts.

## SYNTAX

### Refresh (Default)
```
Update-UnityvCenter [-session <Object>] [-ID] <String[]> [-Refresh] [<CommonParameters>]
```

### RefreshAll
```
Update-UnityvCenter [-session <Object>] [-ID] <String[]> [-RefreshAll] [<CommonParameters>]
```

## DESCRIPTION
Refresh vCenter hosts.
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXEMPLE 1 --------------------------
```
Update-UnityvCenter -ID '' -Refresh
```

Refresh all the hosts managed by this vCenter.

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
ID or Object of a vCenter server

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

### -Refresh
'Refresh all the hosts managed by the host container.

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

### -RefreshAll
Refresh all known vCenters and ESX servers.

```yaml
Type: SwitchParameter
Parameter Sets: RefreshAll
Aliases: 

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE

## RELATED LINKS

[https://github.com/equelin/Unity-Powershell](https://github.com/equelin/Unity-Powershell)


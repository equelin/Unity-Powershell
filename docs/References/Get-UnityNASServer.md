---
external help file: Unity-Powershell-help.xml
online version: https://github.com/equelin/Unity-Powershell
schema: 2.0.0
---

# Get-UnityNASServer

## SYNOPSIS
View details about configured NAS servers.

## SYNTAX

### Name (Default)
```
Get-UnityNASServer [-session <Object>] [-Name <String[]>] [<CommonParameters>]
```

### ID
```
Get-UnityNASServer [-session <Object>] [-ID <String[]>] [<CommonParameters>]
```

## DESCRIPTION
View details about configured NAS servers.
You can filter on ID or Name.
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXEMPLE 1 --------------------------
```
Get-UnityNasServer
```

Retrieve information about all NAS Servers

### -------------------------- EXEMPLE 2 --------------------------
```
Get-UnityNasServer -Name 'NAS01'
```

Retrieves information about NAS server named NAS01

## PARAMETERS

### -session
Specifies an UnitySession Object.

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
Specifies the object name.

```yaml
Type: String[]
Parameter Sets: Name
Aliases: 

Required: False
Position: Named
Default value: *
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -ID
Specifies the object ID.

```yaml
Type: String[]
Parameter Sets: ID
Aliases: 

Required: False
Position: Named
Default value: *
Accept pipeline input: True (ByPropertyName, ByValue)
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


---
external help file: Unity-Powershell-help.xml
online version: https://github.com/equelin/Unity-Powershell
schema: 2.0.0
---

# Get-UnityPoolUnit

## SYNOPSIS
Queries the EMC Unity array to retrieve informations about poolUnit.

## SYNTAX

### Name (Default)
```
Get-UnityPoolUnit [-session <Object>] [-Name <String[]>] [<CommonParameters>]
```

### ID
```
Get-UnityPoolUnit [-session <Object>] [-ID <String[]>] [<CommonParameters>]
```

## DESCRIPTION
Querries the EMC Unity array to retrieve informations about poolUnit.
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXEMPLE 1 --------------------------
```
Get-UnityPoolUnit
```

Retrieve information about poolUnit

### -------------------------- EXEMPLE 2 --------------------------
```
Get-UnityPoolUnit -Name 'POOL01'
```

Retrieves information about poolUnit named POOL01

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
Written by Erwan Quelin under MIT licence

## RELATED LINKS

[https://github.com/equelin/Unity-Powershell](https://github.com/equelin/Unity-Powershell)


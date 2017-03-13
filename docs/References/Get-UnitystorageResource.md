---
external help file: Unity-Powershell-help.xml
online version: https://github.com/equelin/Unity-Powershell
schema: 2.0.0
---

# Get-UnitystorageResource

## SYNOPSIS
Queries the EMC Unity array to retrieve informations about UnitystorageResource.

## SYNTAX

### Name (Default)
```
Get-UnitystorageResource [-session <Object>] [-Name <String[]>] [-Type <String>] [<CommonParameters>]
```

### ID
```
Get-UnitystorageResource [-session <Object>] [-ID <String[]>] [-Type <String>] [<CommonParameters>]
```

## DESCRIPTION
Querries the EMC Unity array to retrieve informations about UnitystorageResource.
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXEMPLE 1 --------------------------
```
Get-UnitystorageResource
```

Retrieve informations about all the storage ressources

### -------------------------- EXEMPLE 2 --------------------------
```
Get-UnitystorageResource -Name 'DATASTORE01'
```

Retrieves informations about storage ressource named DATASTORE01

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

### -Type
Specifies the storage ressource type.
Might be:
- lun
- vmwareiscsi
- vmwarefs

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Written by Erwan Quelin under MIT licence

## RELATED LINKS

[https://github.com/equelin/Unity-Powershell](https://github.com/equelin/Unity-Powershell)


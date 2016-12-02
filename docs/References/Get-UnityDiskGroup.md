---
external help file: Unity-Powershell-help.xml
online version: https://github.com/equelin/Unity-Powershell
schema: 2.0.0
---

# Get-UnityDiskGroup

## SYNOPSIS
View details about disk groups on the system.

## SYNTAX

### ByName (Default)
```
Get-UnityDiskGroup [-session <Object>] [-Name <String[]>]
```

### ByID
```
Get-UnityDiskGroup [-session <Object>] [-ID <String[]>]
```

## DESCRIPTION
View details about disk groups on the system.
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXEMPLE 1 --------------------------
```
Get-UnityDiskGroup
```

Retrieve information about all disk groups

### -------------------------- EXEMPLE 2 --------------------------
```
Get-UnityDiskGroup -Name '200 GB SAS Flash 2'
```

Retrieves information about disk groups names '200 GB SAS Flash 2'

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
Parameter Sets: ByName
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
Parameter Sets: ByID
Aliases: 

Required: False
Position: Named
Default value: *
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES
Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE

## RELATED LINKS

[https://github.com/equelin/Unity-Powershell](https://github.com/equelin/Unity-Powershell)


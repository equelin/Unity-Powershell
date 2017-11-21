# Get-UnityDae

## SYNOPSIS
Information about Disk Array Enclosure (DAE) components in the storage system.

## SYNTAX

### ID (Default)
```
Get-UnityDae [-session <Object>] [-ID <String[]>]
```

### Name
```
Get-UnityDae [-session <Object>] [-Name <String[]>]
```

## DESCRIPTION
Information about Disk Array Enclosure (DAE) components in the storage system.
 
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Get-UnityDae
```

Retrieve Information about Disk Array Enclosure (DAE) components in the storage system.

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
Default value: None
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
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES
Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE

## RELATED LINKS

[https://github.com/equelin/Unity-Powershell](https://github.com/equelin/Unity-Powershell)


# Get-UnityvCenter

## SYNOPSIS
View details about vCenter configuration on the system.

## SYNTAX

### Name (Default)
```
Get-UnityvCenter [-session <Object>] [-Name <String[]>]
```

### ID
```
Get-UnityvCenter [-session <Object>] [-ID <String[]>]
```

## DESCRIPTION
View details about vCenter configuration on the system.
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Get-UnityvCenter
```

Retrieve information about all hosts

### -------------------------- EXAMPLE 2 --------------------------
```
Get-UnityvCenter -Name 'VCENTER01'
```

Retrieves information about vCenter named 'VCENTER01'

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


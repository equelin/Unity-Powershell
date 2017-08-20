# Get-Unitybattery

## SYNOPSIS
(Applies to physical deployments only.) Information about batteries in the storage system.

## SYNTAX

### Name (Default)
```
Get-Unitybattery [-session <Object>] [-Name <String[]>]
```

### ID
```
Get-Unitybattery [-session <Object>] [-ID <String[]>]
```

## DESCRIPTION
(Applies to physical deployments only.) Information about batteries in the storage system.
 
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXEMPLE 1 --------------------------
```
Get-Unitybattery
```

Retrieve information about all Unitybattery

### -------------------------- EXEMPLE 2 --------------------------
```
Get-Unitybattery -ID 'id01'
```

Retrieves information about a specific Unitybattery

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


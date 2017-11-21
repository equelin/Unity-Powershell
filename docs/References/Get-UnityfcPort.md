# Get-UnityFCPort

## SYNOPSIS
Fibre Channel (FC) front end port settings.
Applies if the FC protocol is supported on the system and the corresponding license is installed.

## SYNTAX

### Name (Default)
```
Get-UnityFCPort [-session <Object>] [-Name <String[]>]
```

### ID
```
Get-UnityFCPort [-session <Object>] [-ID <String[]>]
```

## DESCRIPTION
Fibre Channel (FC) front end port settings.
Applies if the FC protocol is supported on the system and the corresponding license is installed.
 
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Get-UnityFCPort
```

Retrieve information about all UnityfcPort

### -------------------------- EXAMPLE 2 --------------------------
```
Get-UnityFCPort -ID 'id01'
```

Retrieves information about a specific UnityfcPort

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


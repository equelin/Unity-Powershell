# Get-UnityHostInitiator

## SYNOPSIS
View details about host initiators.

## SYNTAX

### ID (Default)
```
Get-UnityHostInitiator [-session <Object>] [-ID <String[]>]
```

### PortWwn
```
Get-UnityHostInitiator [-session <Object>] [-PortWWN <String[]>]
```

## DESCRIPTION
View details about host initiators on the system.
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Get-UnityHostInitiator
```

Retrieve information about all hosts

### -------------------------- EXAMPLE 2 --------------------------
```
Get-UnityHostInitiator -ID 'Host_67'
```

Retrieves information about host initiator named 'Host_67'

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

### -PortWWN
Specifies the port WWN.

```yaml
Type: String[]
Parameter Sets: PortWwn
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
Written by Erwan Quélin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE

## RELATED LINKS

[https://github.com/equelin/Unity-Powershell](https://github.com/equelin/Unity-Powershell)


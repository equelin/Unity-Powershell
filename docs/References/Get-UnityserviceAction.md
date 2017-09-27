# Get-UnityServiceAction

## SYNOPSIS
Information about storage system service actions.

## SYNTAX

### Name (Default)
```
Get-UnityServiceAction [-session <Object>] [-Name <String[]>]
```

### ID
```
Get-UnityServiceAction [-session <Object>] [-ID <String[]>]
```

## DESCRIPTION
Information about storage system service actions.
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXEMPLE 1 --------------------------
```
Get-UnityServiceAction
```

Retrieve information about all UnityserviceAction

### -------------------------- EXEMPLE 2 --------------------------
```
Get-UnityServiceAction -ID 'id01'
```

Retrieves information about a specific UnityserviceAction

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


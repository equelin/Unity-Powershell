# Get-UnityHostIPPort

## SYNOPSIS
View details about host IP Port configuration on the system.

## SYNTAX

```
Get-UnityHostIPPort [-session <Object>] [-ID <String[]>]
```

## DESCRIPTION
View details about host IP Port configuration on the system.
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXEMPLE 1 --------------------------
```
Get-UnityHostIPPort
```

Retrieve information about all hosts

### -------------------------- EXEMPLE 2 --------------------------
```
Get-UnityHostIPPort -ID 'ESX01'
```

Retrieves information about host IP Port named 'ESX01'

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
Parameter Sets: (All)
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


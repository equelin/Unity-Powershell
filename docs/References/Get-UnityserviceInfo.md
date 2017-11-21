# Get-UnityServiceInfo

## SYNOPSIS
Service-related storage system information.
You can use this information for servicing the storage system.

## SYNTAX

```
Get-UnityServiceInfo [-session <Object>] [-ID <String[]>]
```

## DESCRIPTION
Service-related storage system information.
You can use this information for servicing the storage system.
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Get-UnityServiceInfo
```

Retrieve information about all UnityserviceInfo

### -------------------------- EXAMPLE 2 --------------------------
```
Get-UnityServiceInfo -ID 'id01'
```

Retrieves information about a specific UnityserviceInfo

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


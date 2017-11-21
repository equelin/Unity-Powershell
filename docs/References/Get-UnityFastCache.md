# Get-UnityFastCache

## SYNOPSIS
View the FAST Cache parameters.

## SYNTAX

```
Get-UnityFastCache [-session <Object>] [-ID <String[]>]
```

## DESCRIPTION
View the FAST Cache parameters.
Physical deployments only.
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Get-UnityFastCache
```

Retrieve information about Fast Cache.

### -------------------------- EXAMPLE 2 --------------------------
```
Get-UnityFastCache -Name '200 GB SAS Flash 2'
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


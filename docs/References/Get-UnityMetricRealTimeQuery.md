# Get-UnityMetricRealTimeQuery

## SYNOPSIS
Information about real times metric queries.

## SYNTAX

```
Get-UnityMetricRealTimeQuery [-session <Object>] [-ID <String[]>]
```

## DESCRIPTION
Information about real times metric queries.
It represents a query to obtain real-time information for one or more metrics, including a specified sampling frequency. 
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Get-UnityMetricRealTimeQuery
```

Retrieve informations about all queries.

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
Queries ID.

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


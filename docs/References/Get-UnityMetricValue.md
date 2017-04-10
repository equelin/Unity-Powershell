# Get-UnityMetricValue

## SYNOPSIS
Historical values for requested metrics.

## SYNTAX

```
Get-UnityMetricValue [[-session] <Object>] [[-Path] <Object[]>] [[-Count] <Int64>]
```

## DESCRIPTION
Historical values for requested metrics. 
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXEMPLE 1 --------------------------
```
Get-UnityMetricValue -Path 'sp.*.cpu.summary.utilization'
```

Retrieves information about metrics who's path is 'sp.*.cpu.summary.utilization'

## PARAMETERS

### -session
Specifies an UnitySession Object.

```yaml
Type: Object
Parameter Sets: (All)
Aliases: 

Required: False
Position: 1
Default value: ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true})
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
Stat path for the metric.
A stat path identifies the metric's location in the stats namespace.

```yaml
Type: Object[]
Parameter Sets: (All)
Aliases: 

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Count
Specifies the number of samples to display.

```yaml
Type: Int64
Parameter Sets: (All)
Aliases: 

Required: False
Position: 3
Default value: 20
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES
Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE

## RELATED LINKS

[https://github.com/equelin/Unity-Powershell](https://github.com/equelin/Unity-Powershell)


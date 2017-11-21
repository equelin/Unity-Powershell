# Save-UnityDataCollectionResult

## SYNOPSIS
Generate and download data collection results

## SYNTAX

```
Save-UnityDataCollectionResult [[-session] <Object>] [[-dataCollectionProfile] <DataCollectionProfileEnum>]
 [-Compress] [[-Path] <String>] [-WhatIf] [-Confirm]
```

## DESCRIPTION
Generate and download data collection results.
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Save-UnityDataCollectionResult -dataCollectionProfile 'default' -Path 'C:' -Compress
```

Generate a default data collection and download it in C: as a ZIP file.

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

### -dataCollectionProfile
The profile used to collect service information.

```yaml
Type: DataCollectionProfileEnum
Parameter Sets: (All)
Aliases: 
Accepted values: Default, Performance_Assessment, Performance_Trace, Other

Required: False
Position: 2
Default value: Default
Accept pipeline input: False
Accept wildcard characters: False
```

### -Compress
Specifies if you want to compress the downloaded file

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
Specifies where to store downloaded Data Collection Results

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 3
Default value: .
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES
Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE

## RELATED LINKS

[https://github.com/equelin/Unity-Powershell](https://github.com/equelin/Unity-Powershell)


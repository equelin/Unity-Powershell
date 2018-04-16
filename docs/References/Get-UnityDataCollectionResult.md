# Get-UnityDataCollectionResult

## SYNOPSIS
Get or download informations about Data Collection results

## SYNTAX

### ID (Default)
```
Get-UnityDataCollectionResult [-session <Object>] [-ID <String[]>] [-Download] [-Compress] [-Path <String>]
```

### Name
```
Get-UnityDataCollectionResult [-session <Object>] [-Name <String[]>] [-Download] [-Compress] [-Path <String>]
```

## DESCRIPTION
Information about Data Collection results in the storage system.
Data Collection is a service feature used for gathering system logs, customer configurations, system statistics and runtime data from storage system.
 
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Get-UnityDataCollectionResultList
```

Retrieve information about all UnitydataCollectionResult

### -------------------------- EXAMPLE 2 --------------------------
```
Get-UnityDataCollectionResultList -ID 'id01'
```

Retrieves information about a specific UnitydataCollectionResult

### -------------------------- EXAMPLE 3 --------------------------
```
Get-UnityDataCollectionResultList -ID 'id01' -Download -Path C:\Temp
```

Download Data Collection Result in C:\Temp

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

### -Download
Specifies if you want to download Data Collection Results

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
Position: Named
Default value: .
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES
Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE

## RELATED LINKS

[https://github.com/equelin/Unity-Powershell](https://github.com/equelin/Unity-Powershell)


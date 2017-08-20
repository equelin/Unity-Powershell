# Get-UnitydataCollectionResult

## SYNOPSIS
Information about Data Collection results in the storage system.
\<br/\> \<br/\> Data Collection is a service feature used for gathering system logs, customer configurations, system statistics and runtime data from storage system.
\<br/\> \<br/\>

## SYNTAX

### Name (Default)
```
Get-UnitydataCollectionResult [-session <Object>] [-Name <String[]>] [-Download] [-Path <String>]
```

### ID
```
Get-UnitydataCollectionResult [-session <Object>] [-ID <String[]>] [-Download] [-Path <String>]
```

## DESCRIPTION
Information about Data Collection results in the storage system.
\<br/\> \<br/\> Data Collection is a service feature used for gathering system logs, customer configurations, system statistics and runtime data from storage system.
\<br/\> \<br/\>  
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXEMPLE 1 --------------------------
```
Get-UnitydataCollectionResultList
```

Retrieve information about all UnitydataCollectionResult

### -------------------------- EXEMPLE 2 --------------------------
```
Get-UnitydataCollectionResultList -ID 'id01'
```

Retrieves information about a specific UnitydataCollectionResult

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
Download the file(s)

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Path
Download path

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: .
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES
Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE

## RELATED LINKS

[https://github.com/equelin/Unity-Powershell](https://github.com/equelin/Unity-Powershell)


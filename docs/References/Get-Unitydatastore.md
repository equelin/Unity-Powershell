# Get-UnityDatastore

## SYNOPSIS
Represents a VMware Datastore.

## SYNTAX

### Name (Default)
```
Get-UnityDatastore [-session <Object>] [-Name <String[]>]
```

### ID
```
Get-UnityDatastore [-session <Object>] [-ID <String[]>]
```

## DESCRIPTION
Represents a VMware Datastore.
 
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXEMPLE 1 --------------------------
```
Get-UnityDatastore
```

Retrieve information about all Unitydatastore

### -------------------------- EXEMPLE 2 --------------------------
```
Get-UnityDatastore -ID 'id01'
```

Retrieves information about a specific Unitydatastore

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


# Get-UnityStorageResource

## SYNOPSIS
Queries the EMC Unity array to retrieve informations about UnitystorageResource.

## SYNTAX

### Name (Default)
```
Get-UnityStorageResource [-session <Object>] [-Name <String[]>] [-Type <String>]
```

### ID
```
Get-UnityStorageResource [-session <Object>] [-ID <String[]>] [-Type <String>]
```

## DESCRIPTION
Querries the EMC Unity array to retrieve informations about UnitystorageResource.
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Get-UnityStorageResource
```

Retrieve informations about all the storage ressources

### -------------------------- EXAMPLE 2 --------------------------
```
Get-UnityStorageResource -Name 'DATASTORE01'
```

Retrieves informations about storage ressource named DATASTORE01

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

### -Type
Specifies the storage ressource type.
Might be:
- lun
- vmwareiscsi
- vmwarefs

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES
Written by Erwan Quelin under MIT licence

## RELATED LINKS

[https://github.com/equelin/Unity-Powershell](https://github.com/equelin/Unity-Powershell)


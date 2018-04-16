# Get-UnityVMwarePE

## SYNOPSIS
A resource representing VMware protocol endpoint of both possible types: NAS protocol endpoint and SCSI protocol endpoint.
An instance of this class is created automatically as part of VVol datastore (storage resource) host access configuration.

## SYNTAX

### Name (Default)
```
Get-UnityVMwarePE [-session <Object>] [-Name <String[]>]
```

### ID
```
Get-UnityVMwarePE [-session <Object>] [-ID <String[]>]
```

## DESCRIPTION
A resource representing VMware protocol endpoint of both possible types: NAS protocol endpoint and SCSI protocol endpoint.
An instance of this class is created automatically as part of VVol datastore (storage resource) host access configuration.
 
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Get-UnityVMwarePE
```

Retrieve information about all UnityvmwarePE

### -------------------------- EXAMPLE 2 --------------------------
```
Get-UnityVMwarePE -ID 'id01'
```

Retrieves information about a specific UnityvmwarePE

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


# Get-UnityVMwareNFS

## SYNOPSIS
Queries the EMC Unity array to retrieve informations about VMware NFS LUN.

## SYNTAX

### ID (Default)
```
Get-UnityVMwareNFS [-session <Object>] [-ID <String[]>]
```

### Name
```
Get-UnityVMwareNFS [-session <Object>] [-Name <String[]>]
```

## DESCRIPTION
Querries the EMC Unity array to retrieve informations about VMware NFS LUN.
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXEMPLE 1 --------------------------
```
Get-UnityVMwareNFS
```

Retrieve information about all VMware NFS LUN

### -------------------------- EXEMPLE 2 --------------------------
```
Get-UnityVMwareNFS -Name 'DATASTORE01'
```

Retrieves information about VMware NFS LUN named DATASTORE01

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
Default value: *
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
Default value: *
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES
Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE

## RELATED LINKS

[https://github.com/equelin/Unity-Powershell](https://github.com/equelin/Unity-Powershell)


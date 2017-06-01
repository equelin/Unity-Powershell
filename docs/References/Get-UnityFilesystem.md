# Get-UnityFilesystem

## SYNOPSIS
Queries the EMC Unity array to retrieve informations about filesystems.

## SYNTAX

### Name (Default)
```
Get-UnityFilesystem [-session <Object>] [-Name <String[]>] [-Typename <String>]
```

### ID
```
Get-UnityFilesystem [-session <Object>] [-ID <String[]>] [-Typename <String>]
```

## DESCRIPTION
Querries the EMC Unity array to retrieve informations about filesystems.
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXEMPLE 1 --------------------------
```
Get-UnityFilesystem
```

Retrieve information about filesystem

### -------------------------- EXEMPLE 2 --------------------------
```
Get-UnityFilesystem -Name 'FS01'
```

Retrieves information about filesystem named FS01

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

### -Typename
Specifies the object type.
Might be UnityFilesystem (default) or UnityVMwareNFS

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: UnityFilesystem
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES
Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE

## RELATED LINKS

[https://github.com/equelin/Unity-Powershell](https://github.com/equelin/Unity-Powershell)


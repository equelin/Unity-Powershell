# Get-UnityInstalledSoftwareVersion

## SYNOPSIS
Information about installed system software and language packs in the VNXe system.

## SYNTAX

### Name (Default)
```
Get-UnityInstalledSoftwareVersion [-session <Object>]
```

### ID
```
Get-UnityInstalledSoftwareVersion [-session <Object>] [-ID <String[]>]
```

## DESCRIPTION
Information about installed system software and language packs in the VNXe system.
 
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXEMPLE 1 --------------------------
```
Get-UnityInstalledSoftwareVersion
```

Retrieve information about all UnityinstalledSoftwareVersion

### -------------------------- EXEMPLE 2 --------------------------
```
Get-UnityInstalledSoftwareVersion -ID 'id01'
```

Retrieves information about a specific UnityinstalledSoftwareVersion

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


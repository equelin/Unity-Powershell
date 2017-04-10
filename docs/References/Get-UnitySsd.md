# Get-UnitySsd

## SYNOPSIS
Information about internal Flash-based Solid State Disks (SSDs, mSATAs) in the storage system.

## SYNTAX

### ID (Default)
```
Get-UnitySsd [-session <Object>] [-ID <String[]>]
```

### Name
```
Get-UnitySsd [-session <Object>] [-Name <String[]>]
```

## DESCRIPTION
Information about internal Flash-based Solid State Disks (SSDs, mSATAs) in the storage system.
Applies to physical deployments only.
 
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXEMPLE 1 --------------------------
```
Get-UnitySsd
```

Retrieve Information about SSD.

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
SSD Name

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


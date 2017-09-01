# Get-UnityMgmtInterfaceSetting

## SYNOPSIS
Informations about global settings for the management interfaces.

## SYNTAX

```
Get-UnityMgmtInterfaceSetting [[-session] <Object>]
```

## DESCRIPTION
Informations about global settings for the management interfaces.
 
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXEMPLE 1 --------------------------
```
Get-UnityMgmtInterfaceSetting
```

Retrieve informations about global settings for the management interfaces.

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

## INPUTS

## OUTPUTS

## NOTES
Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE

## RELATED LINKS

[https://github.com/equelin/Unity-Powershell](https://github.com/equelin/Unity-Powershell)


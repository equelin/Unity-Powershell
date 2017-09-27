# Get-UnitySession

## SYNOPSIS
List the existing sessions.

## SYNTAX

```
Get-UnitySession [[-Server] <String>]
```

## DESCRIPTION
List the existing sessions.

## EXAMPLES

### -------------------------- EXEMPLE 1 --------------------------
```
Get-UnitySession
```

List all the existing sessions.

### -------------------------- EXEMPLE 2 --------------------------
```
Get-UnitySession -Server 192.0.2.1'
```

Lists sessions connected the the array '192.0.2.1'

## PARAMETERS

### -Server
IP or FQDN of the Unity array.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 1
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


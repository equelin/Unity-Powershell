---
external help file: Unity-Powershell-help.xml
online version: https://github.com/equelin/Unity-Powershell
schema: 2.0.0
---

# Get-UnitySession

## SYNOPSIS
List the existing sessions.

## SYNTAX

```
Get-UnitySession [[-Server] <String>] [<CommonParameters>]
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
Get-UnitySession -Server 192.168.0.1'
```

Lists sessions connected the the array '192.168.0.1'

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Written by Erwan Quelin under MIT licence

## RELATED LINKS

[https://github.com/equelin/Unity-Powershell](https://github.com/equelin/Unity-Powershell)


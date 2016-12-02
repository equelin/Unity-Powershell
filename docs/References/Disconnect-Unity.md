---
external help file: Unity-Powershell-help.xml
online version: https://github.com/equelin/Unity-Powershell
schema: 2.0.0
---

# Disconnect-Unity

## SYNOPSIS
Disconnects from an EMC Unity Array

## SYNTAX

```
Disconnect-Unity [[-session] <UnitySession[]>] [-WhatIf] [-Confirm]
```

## DESCRIPTION
Disconnects from an EMC Unity Array.
By default, Disconnect-Unity closes all sessions.
To close a specific session, use the -Session parameter.
When a session is disconnected, it is removed form the default array list.

## EXAMPLES

### -------------------------- EXEMPLE 1 --------------------------
```
Disconnect-Unity
```

Disconnects all the sessions

### -------------------------- EXEMPLE 2 --------------------------
```
$Session = Get-UnitySession -Server 192.168.0.1
```

Disconnect-Unity -Session $Session

Disconnects all the sessions matching the IP of the array 192.168.0.1

## PARAMETERS

### -session
Specifies an UnitySession Object.

```yaml
Type: UnitySession[]
Parameter Sets: (All)
Aliases: 

Required: False
Position: 1
Default value: $global:DefaultUnitySession
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES
Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE

## RELATED LINKS

[https://github.com/equelin/Unity-Powershell](https://github.com/equelin/Unity-Powershell)


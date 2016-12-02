---
external help file: Unity-Powershell-help.xml
online version: https://github.com/equelin/Unity-Powershell
schema: 2.0.0
---

# Disable-UnityFastCache

## SYNOPSIS
Disable FAST Cache.

## SYNTAX

```
Disable-UnityFastCache [[-session] <UnitySession[]>] [-WhatIf] [-Confirm]
```

## DESCRIPTION
Disable FAST Cache.
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXEMPLE 1 --------------------------
```
Disable-UnityFastCache
```

Disable FAST Cache.

## PARAMETERS

### -session
Specifies an UnitySession Object.

```yaml
Type: UnitySession[]
Parameter Sets: (All)
Aliases: 

Required: False
Position: 1
Default value: ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true})
Accept pipeline input: False
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


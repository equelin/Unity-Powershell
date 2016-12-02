---
external help file: Unity-Powershell-help.xml
online version: https://github.com/equelin/Unity-Powershell
schema: 2.0.0
---

# Test-UnityUCAlert

## SYNOPSIS
Test Unisphere Central alert notification by sending a test alert to a Unisphere Central destination.

## SYNTAX

```
Test-UnityUCAlert [-session <Object>] [[-ID] <String[]>]
```

## DESCRIPTION
Test Unisphere Central alert notification by sending a test alert to a Unisphere Central destination. 
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXEMPLE 1 --------------------------
```
Test-UnityUCAlert
```

Test Unisphere Central alert notification by sending a test alert to a Unisphere Central destination.

## PARAMETERS

### -session
Specify an UnitySession Object.

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
ID or Object of a Alert Config..

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 

Required: False
Position: 1
Default value: 0
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES
Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE

## RELATED LINKS

[https://github.com/equelin/Unity-Powershell](https://github.com/equelin/Unity-Powershell)


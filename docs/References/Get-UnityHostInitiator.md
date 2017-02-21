---
external help file: Unity-Powershell-help.xml
online version: https://github.com/equelin/Unity-Powershell
schema: 2.0.0
---

# Get-UnityHostInitiator

## SYNOPSIS
View details about host initiator configuration on the system.

## SYNTAX

### ByID
```
Get-UnityHostInitiator [-session <Object>] [-ID <String[]>]
```

### ByPortWwn
```
Get-UnityHostInitiator [-session <Object>] [-PortWWN <String[]>]
```

## DESCRIPTION
View details about host initiator configuration on the system.
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Get-UnityHostInitiator
```

Retrieve information about all hosts initiators

### -------------------------- EXAMPLE 2 --------------------------
```
Get-UnityHostInitiator -PortWWN "*00:12:55" 
```

Retrieves information about the host initiator with a PortWWN ending in '00:12:55'.

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
Parameter Sets: ByID
Aliases: 

Required: False
Position: Named
Default value: *
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -PortWWN
Specifies the port WWN.

```yaml
Type: String[]
Parameter Sets: ByPortWwn
Aliases:

Required: False
Position: Named
Default value: *
Accept pipeline input: True (ByValue, ByPropertyName)
Accept wildcard characters: False
```

## INPUTS

```yaml
[String[]]
```

Accepts Id or PortWWN on the pipeline.

## OUTPUTS

```yaml
[Object[]]
```

Returns an Object array with elements of type [UnitHostInitiator].

## NOTES
Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE

## RELATED LINKS

[https://github.com/equelin/Unity-Powershell](https://github.com/equelin/Unity-Powershell)


# Test-UnityEmailAlert

## SYNOPSIS
Test email alert notification by sending a test alert to all configured email destinations.

## SYNTAX

```
Test-UnityEmailAlert [-session <Object>] [[-ID] <Object[]>]
```

## DESCRIPTION
Test email alert notification by sending a test alert to all configured email destinations. 
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Test-UnityEmailAlert
```

Test email alert notification by sending a test alert to all configured email destinations.

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
Type: Object[]
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


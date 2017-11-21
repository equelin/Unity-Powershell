# Get-UnityX509Certificate

## SYNOPSIS
Information about the X.509 certificates installed on the storage system.
The X.509 certificate format is described in RFC 5280.

## SYNTAX

```
Get-UnityX509Certificate [-session <Object>] [-ID <String[]>]
```

## DESCRIPTION
Information about the X.509 certificates installed on the storage system.
The X.509 certificate format is described in RFC 5280.
 
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Get-UnityX509Certificate
```

Retrieve information about all Unityx509Certificate

### -------------------------- EXAMPLE 2 --------------------------
```
Get-UnityX509Certificate -ID 'id01'
```

Retrieves information about a specific Unityx509Certificate

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
Parameter Sets: (All)
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


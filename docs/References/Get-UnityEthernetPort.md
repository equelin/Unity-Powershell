# Get-UnityEthernetPort

## SYNOPSIS
Queries the EMC Unity array to retrieve informations about Ethernet Ports.

## SYNTAX

### Name (Default)
```
Get-UnityEthernetPort [-session <Object>] [-Name <String[]>]
```

### ID
```
Get-UnityEthernetPort [-session <Object>] [-ID <String[]>]
```

## DESCRIPTION
Queries the EMC Unity array to retrieve informations about Ethernet Ports.
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Get-UnityEthernetPort
```

Retrieve information about all ethernet ports

### -------------------------- EXAMPLE 2 --------------------------
```
Get-UnityEthernetPort -Name 'Ethernet Ports01'
```

Retrieves information about ethernet port named 'Ethernet Ports01'

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
Specifies the object name.

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


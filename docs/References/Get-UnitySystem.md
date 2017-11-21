# Get-UnitySystem

## SYNOPSIS
Information about general settings for the storage system.

## SYNTAX

### Name (Default)
```
Get-UnitySystem [-session <Object>] [-Name <String[]>]
```

### ID
```
Get-UnitySystem [-session <Object>] [-ID <String[]>]
```

## DESCRIPTION
Information about general settings for the storage system.
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Get-UnitySystem
```

Retrieve informations about all the arrays with an active session.

### -------------------------- EXAMPLE 2 --------------------------
```
Get-UnitySystem -Name 'UnityVSA'
```

Retrieves informations about an array named 'UnityVSA'

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
Written by Erwan Quelin under MIT licence

## RELATED LINKS

[https://github.com/equelin/Unity-Powershell](https://github.com/equelin/Unity-Powershell)


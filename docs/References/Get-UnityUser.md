# Get-UnityUser

## SYNOPSIS
Information about local users, including their roles, and how they are authenticated.

## SYNTAX

### Name (Default)
```
Get-UnityUser [-session <Object>] [-Name <String[]>]
```

### ID
```
Get-UnityUser [-session <Object>] [-ID <String[]>]
```

## DESCRIPTION
Information about local users, including their roles, and how they are authenticated.
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Get-UnityUser
```

Retrieve informations about all the local users

### -------------------------- EXAMPLE 2 --------------------------
```
Get-UnityUser -Name 'administrator'
```

Retrieves informations about the local user named 'administrator'

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


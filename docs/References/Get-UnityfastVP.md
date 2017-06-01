# Get-UnityfastVP

## SYNOPSIS
System FAST VP settings.
FAST VP allows performing automatic data relocation between tiers and rebalancing within a tier to improve storage performance.
Currently there three types of relocations supported: \<br/\> \<li\>Scheduled relocations\</li\> \<li\>Manual relocations\</li\> \<li\>Rebalancing\</li\> \<br/\> Scheduled relocations are started according the schedule defined in this resource.
Individual pools can be included to or excluded from the scheduled relocation process.
\<br/\> Manual relocations can be performed on demand for each particular pool.
\<br/\> Rebalancing is performed automatically on a pool extend event.
\<br/\> The FAST VP object represents the status of scheduled relocation processes and allows to view or modify the scheduled relocation parameters.
It also provides a means to pause or resume all the FAST VP relocation and rebalancing processes currently running on the system.

## SYNTAX

### Name (Default)
```
Get-UnityfastVP [-session <Object>]
```

### ID
```
Get-UnityfastVP [-session <Object>] [-ID <String[]>]
```

## DESCRIPTION
System FAST VP settings.
FAST VP allows performing automatic data relocation between tiers and rebalancing within a tier to improve storage performance.
Currently there three types of relocations supported: \<br/\> \<li\>Scheduled relocations\</li\> \<li\>Manual relocations\</li\> \<li\>Rebalancing\</li\> \<br/\> Scheduled relocations are started according the schedule defined in this resource.
Individual pools can be included to or excluded from the scheduled relocation process.
\<br/\> Manual relocations can be performed on demand for each particular pool.
\<br/\> Rebalancing is performed automatically on a pool extend event.
\<br/\> The FAST VP object represents the status of scheduled relocation processes and allows to view or modify the scheduled relocation parameters.
It also provides a means to pause or resume all the FAST VP relocation and rebalancing processes currently running on the system.
 
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXEMPLE 1 --------------------------
```
Get-UnityfastVP
```

Retrieve information about all UnityfastVP

### -------------------------- EXEMPLE 2 --------------------------
```
Get-UnityfastVP -ID 'id01'
```

Retrieves information about a specific UnityfastVP

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


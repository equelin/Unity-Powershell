# Get-UnityItem

## SYNOPSIS
Queries the EMC Unity array to retrieve informations about a specific item.

## SYNTAX

```
Get-UnityItem [[-session] <Object>] [-URI] <String> [-JSON]
```

## DESCRIPTION
Querries the EMC Unity array to retrieve informations about a specific item.
You need to provide the URI of the item (ex: /api/types/pool/instances)  with the parameter -URI.
By default, the response is a powershell object.
You can retrieve the JSON response by using the -JSON parameter.
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXEMPLE 1 --------------------------
```
Get-UnityItem -URI '/api/types/pool/instances'
```

Retrieve information about pools. 
Return a powershell object

### -------------------------- EXEMPLE 2 --------------------------
```
Get-UnityItem -URI '/api/types/pool/instances' -JSON
```

Retrieves information about pools.
Return data in the JSON format

## PARAMETERS

### -session
Specifies an UnitySession Object.

```yaml
Type: Object
Parameter Sets: (All)
Aliases: 

Required: False
Position: 1
Default value: ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true})
Accept pipeline input: False
Accept wildcard characters: False
```

### -URI
URI of the Unity ressource (ex: /api/types/lun/instances)

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -JSON
Output in the JSON Format

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES
Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE

## RELATED LINKS

[https://github.com/equelin/Unity-Powershell](https://github.com/equelin/Unity-Powershell)


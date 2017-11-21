# Get-UnityVMwareNasPEServer

## SYNOPSIS
A resource representing NAS VMware Protocol Endpoint Server.
Only one instance per NAS Server can be created.

## SYNTAX

### Name (Default)
```
Get-UnityVMwareNasPEServer [-session <Object>]
```

### ID
```
Get-UnityVMwareNasPEServer [-session <Object>] [-ID <String[]>]
```

## DESCRIPTION
A resource representing NAS VMware Protocol Endpoint Server.
Only one instance per NAS Server can be created.
 
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Get-UnityVMwareNasPEServer
```

Retrieve information about all UnityvmwareNasPEServer

### -------------------------- EXAMPLE 2 --------------------------
```
Get-UnityVMwareNasPEServer -ID 'id01'
```

Retrieves information about a specific UnityvmwareNasPEServer

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


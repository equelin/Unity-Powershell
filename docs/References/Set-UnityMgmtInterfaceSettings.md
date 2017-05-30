# Set-UnityMgmtInterfaceSettings

## SYNOPSIS
Modifies global management interfaces settings.

## SYNTAX

```
Set-UnityMgmtInterfaceSettings [[-session] <Object>] [[-v4ConfigMode] <InterfaceConfigModeEnum>]
 [[-v6ConfigMode] <InterfaceConfigModeEnum>] [-WhatIf] [-Confirm]
```

## DESCRIPTION
Modifies global management interfaces settings.
It is not allowed to set both IPv4 and IPv6 to Disabled at the same time, in any sequence.
It is not allowed to set both IPv4 and IPv6 to Auto in one request.
IPv4 or IPv6 may be set to Auto only if the other class IP address already exists, either set as a static IP address or obtained in Auto mode.
The Static can be set only implicitly by creating the mgmtInterface object. 
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXEMPLE 1 --------------------------
```
Set-UnityMgmtInterfaceSettings -Addresses '192.0.2.1','192.0.2.2'
```

replace the exsting address list for this DNS server with this new list.

## PARAMETERS

### -session
Specify an UnitySession Object.

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

### -v4ConfigMode
New IPv4 config mode.
Might be:
- Disabled: Management access is disabled. 
- Static: Management interface address is set manually with Set-UnityMgmtInterface.
- Auto: Management interface address is configured by DHCP.

```yaml
Type: InterfaceConfigModeEnum
Parameter Sets: (All)
Aliases: 
Accepted values: Disabled, Static, Auto

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -v6ConfigMode
New IPv6 config mode.
Might be:
- Disabled: Management access is disabled. 
- Static: Management interface address is set manually with Set-UnityMgmtInterface.
- Auto: Management interface address is configured by SLAAC.

```yaml
Type: InterfaceConfigModeEnum
Parameter Sets: (All)
Aliases: 
Accepted values: Disabled, Static, Auto

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES
Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE

## RELATED LINKS

[https://github.com/equelin/Unity-Powershell](https://github.com/equelin/Unity-Powershell)


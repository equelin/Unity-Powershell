# New-UnityiSCSIPortal

## SYNOPSIS
Create a new iSCSI portal.

## SYNTAX

```
New-UnityiSCSIPortal [[-session] <Object>] [-ethernetPort] <String> [-ipAddress] <String> [[-netmask] <String>]
 [[-v6PrefixLength] <String[]>] [[-vlanId] <String[]>] [[-gateway] <String>] [-WhatIf] [-Confirm]
```

## DESCRIPTION
Create a new iSCSI portal.
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXEMPLE 1 --------------------------
```
New-UnityiSCSIPortal -ethernetPort 'spa_eth0' -ipAddress '192.0.2.1' -netmask '255.255.255.0' -gateway '192.0.2.254'
```

Create a new iSCSI portal.

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

### -ethernetPort
Ethernet port used by the iSCSI portal.

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

### -ipAddress
IPv4 or IPv6 address for the iSCSI Network Portal.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -netmask
IPv4 netmask for the iSCSI Network Portal, if the iSCSI Network Portal uses an IPv4 address.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -v6PrefixLength
Prefix length in bits for IPv6 address.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -vlanId
Ethernet virtual LAN identifier used for tagging iSCSI portal outgoing packets and for filtering iSCSI portal incoming packets.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -gateway
IPv4 or IPv6 gateway address for the iSCSI Network Portal.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Indicate that the cmdlet is run only to display the changes that would be made and actually no objects are modified.

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
If the value is $true, indicates that the cmdlet asks for confirmation before running.
If the value is $false, the cmdlet runs without asking for user confirmation.

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


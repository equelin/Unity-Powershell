# Set-UnityIscsiPortal

## SYNOPSIS
Modify an iSCSI network portal.

## SYNTAX

```
Set-UnityIscsiPortal [-session <Object>] [-ID] <Object[]> [-ipAddress <String>] [-netmask <String>]
 [-v6PrefixLength <String[]>] [-vlanId <String[]>] [-gateway <String>] [-WhatIf] [-Confirm]
```

## DESCRIPTION
Modify an iSCSI network portal. 
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Set-UnityIscsiPortal -ID 'if_6' -vlanId 10
```

Modifies the iSCSI network portal with id 'if_6'

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
iSCSI Network Portal ID or Object.

```yaml
Type: Object[]
Parameter Sets: (All)
Aliases: 

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -ipAddress
IPv4 or IPv6 address for the iSCSI Network Portal.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
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
Position: Named
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
Position: Named
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
Position: Named
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
Position: Named
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


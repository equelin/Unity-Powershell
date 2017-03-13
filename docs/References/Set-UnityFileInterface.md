---
external help file: Unity-Powershell-help.xml
online version: https://github.com/equelin/Unity-Powershell
schema: 2.0.0
---

# Set-UnityFileInterface

## SYNOPSIS
Modifies NAS Server parameters.

## SYNTAX

```
Set-UnityFileInterface [-session <Object>] [[-ID] <Object>] [-ipPort <Object>] [-ipAddress <IPAddress>]
 [-netmask <IPAddress>] [-v6PrefixLength <String>] [-gateway <IPAddress>] [-vlanId <Int32>]
 [-isPreferred <Boolean>] [-replicationPolicy <ReplicationPolicyEnum>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Modifies NAS Server parameters.
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXEMPLE 1 --------------------------
```
Set-UnityFileInterface -ID 'if_1' -ipAddress '192.168.0.1'
```

Change ip of the file interface with ID 'if_1'

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
File interface ID or Object

```yaml
Type: Object
Parameter Sets: (All)
Aliases: 

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -ipPort
Physical port or link aggregation on the storage processor on which the interface is running

```yaml
Type: Object
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ipAddress
IP address of the network interface

```yaml
Type: IPAddress
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -netmask
IPv4 netmask for the network interface, if it uses an IPv4 address

```yaml
Type: IPAddress
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -v6PrefixLength
IPv6 prefix length for the interface, if it uses an IPv6 address

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

### -gateway
IPv4 or IPv6 gateway address for the network interface

```yaml
Type: IPAddress
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -vlanId
LAN identifier for the interface.
The interface uses the identifier to accept packets that have matching VLAN tags.
Values are 1 - 4094.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -isPreferred
Sets the current IP interface as preferred for associated for file-based storage and unsets the previous one

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -replicationPolicy
Indicates the status of the NAS server object operating as a replication destination

```yaml
Type: ReplicationPolicyEnum
Parameter Sets: (All)
Aliases: 
Accepted values: Not_Replicated, Replicated, Overridden

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE

## RELATED LINKS

[https://github.com/equelin/Unity-Powershell](https://github.com/equelin/Unity-Powershell)


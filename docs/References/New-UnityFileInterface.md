# New-UnityFileInterface

## SYNOPSIS
Creates a File Interface.

## SYNTAX

```
New-UnityFileInterface [-session <Object>] [-nasServer] <Object> -ipPort <Object> -ipAddress <IPAddress>
 [-netmask <IPAddress>] [-v6PrefixLength <String>] [-gateway <IPAddress>] [-vlanId <Int32>]
 [-isPreferred <Boolean>] [-role <FileInterfaceRoleEnum>] [-WhatIf] [-Confirm]
```

## DESCRIPTION
Creates a File Interface.
These interfaces control access to Windows (CIFS) and UNIX/Linux (NFS) file storage.
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
New-UnityFileInterface -ipPort spa_eth0 -nasServer nas_6 -ipAddress 192.0.2.1 -netmask 255.255.255.0 -gateway 192.0.2.254
```

Create interface on the ethernet port 'spa_eth0' associated to the NAS server 'nas_6'

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

### -nasServer
ID of the NAS server to which the network interface belongs

```yaml
Type: Object
Parameter Sets: (All)
Aliases: 

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ipPort
Physical port or link aggregation on the storage processor on which the interface is running

```yaml
Type: Object
Parameter Sets: (All)
Aliases: 

Required: True
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

Required: True
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

### -role
Role of NAS server network interface

```yaml
Type: FileInterfaceRoleEnum
Parameter Sets: (All)
Aliases: 
Accepted values: Production, Backup

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


# Set-UnityHostIPPort

## SYNOPSIS
Modify a host IP Port configuration.

## SYNTAX

```
Set-UnityHostIPPort [-session <Object>] [-ID] <Object> [-address <String>] [-netmask <String>]
 [-v6PrefixLength <String>] [-isIgnored <Boolean>] [-WhatIf] [-Confirm]
```

## DESCRIPTION
Modify a host IP Port configuration. 
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXEMPLE 1 --------------------------
```
Set-UnityHostIPPort -ID 'HostNetworkAddress_47' -address '192.168.0.1'
```

Change the IP of the host.

### -------------------------- EXEMPLE 2 --------------------------
```
Get-UnityHostIPPort -ID 'HostNetworkAddress_47' | Set-UnityHostIPPort -address '192.168.0.1'
```

Gives the role 'operator' to the Host IP Port 'Host'.
The Host's information are provided by the Get-UnityHostIPPort through the pipeline.

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
Host IP Port ID or Object

```yaml
Type: Object
Parameter Sets: (All)
Aliases: 

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -address
IP address or network name of the port.

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
(Applies to IPV4 only.) Subnet mask for the IP address, if any.

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
(Applies to IPV6 only.) Subnet mask length.

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

### -isIgnored
(Applies to NFS access only.) Indicates whether the port should be ignored when storage access is granted to the host

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
If the value is $false, the cmdlet runs without asking for Host IP Port confirmation.

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


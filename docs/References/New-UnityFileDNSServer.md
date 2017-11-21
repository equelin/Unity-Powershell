# New-UnityFileDNSServer

## SYNOPSIS
Create a new DNS server for a NAS Server.

## SYNTAX

```
New-UnityFileDNSServer [-session <Object>] [-nasServer] <Object> -domain <String> -addresses <String[]>
 [-WhatIf] [-Confirm]
```

## DESCRIPTION
Create a new DNS server for a NAS Server.
Only one instance can be created per NAS server.
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
New-UnityFileDNSServer -nasServer 'nas_1' -domain 'example.com' -ip '192.0.2.1','192.0.2.2'
```

Create a DNS file server associated to NAS server 'nas_1'

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
ID of the NAS server to which the DNS server belongs.

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

### -domain
DNS domain name

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -addresses
Prioritized list of one to three IPv4 and/or IPv6 addresses of DNS server(s) for the domain

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 

Required: True
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


# New-UnityNASServer

## SYNOPSIS
Creates a NAS Server.

## SYNTAX

```
New-UnityNASServer [-session <Object>] [-Name] <String[]> -homeSP <Object> -Pool <String>
 [-isReplicationDestination <Boolean>] [-UnixDirectoryService <NasServerUnixDirectoryServiceEnum>]
 [-isMultiProtocolEnabled <Boolean>] [-allowUnmappedUser <Boolean>] [-defaultUnixUser <String>]
 [-defaultWindowsUser <String>] [-WhatIf] [-Confirm]
```

## DESCRIPTION
Create a NAS server.
You can create a maximum of 24 NAS servers per system.
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
New-UnityNasServer -Name 'NAS01' -Pool 'pool_1' -homeSP 'spa'
```

Create NAS server named 'NAS01' on the pool ID 'pool_1' and attached to the sp 'spa'

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

### -Name
Specifies the NAS server name.
NAS server names can contain alphanumeric characters, a single dash, and a single underscore. 
Server names cannot contain spaces or begin or end with a dash. 
You can create NAS server names in four parts that are separated by periods (example: aa.bb.cc.dd).
Names can contain up to 255 characters, but the first part of the name (before the first period) is limited to 15 characters.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -homeSP
Specifies the parent SP for the NAS server.

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

### -Pool
Specifies the ID of the storage pool for the NAS server.

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

### -isReplicationDestination
Replication destination settings for the NAS server.
When this option is set to yes, only mandatory parameters may be included. 
All other optional parameters will be inherited from the source NAS server.
Valid values are $true or $false (default).

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

### -UnixDirectoryService
Directory Service used for querying identity information for Unix (such as UIDs, GIDs, net groups).
Valid values are:
- NIS
- LDAP
- None (Default)

```yaml
Type: NasServerUnixDirectoryServiceEnum
Parameter Sets: (All)
Aliases: 
Accepted values: None, NIS, LDAP, LocalThenNIS, LocalThenLDAP

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -isMultiProtocolEnabled
Indicates whether multiprotocol sharing mode is enabled.
Value is $true or $false (default).

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

### -allowUnmappedUser
Use this flag to mandatorily disable access in case of any user mapping failure.
Valide value are $true or $false (default).

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

### -defaultUnixUser
Default Unix user name that grants file access in the multiprotocol sharing mode.
This user name is used when the corresponding Unix/Linux user name is not found by the mapping mechanism.

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

### -defaultWindowsUser
Default Windows user name that grants file access in the multiprotocol sharing mode. 
This user name is used when the corresponding Windows user name is not found by the mapping mechanism.

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


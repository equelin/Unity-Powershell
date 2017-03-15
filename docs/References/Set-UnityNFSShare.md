---
external help file: Unity-Powershell-help.xml
online version: https://github.com/equelin/Unity-Powershell
schema: 2.0.0
---

# Set-UnityNFSShare

## SYNOPSIS
Modifies NFS share.

## SYNTAX

```
Set-UnityNFSShare [-session <Object>] [-ID] <String[]> [-description <String>] [-isReadOnly <Boolean>]
 [-defaultAccess <NFSShareDefaultAccessEnum>] [-minSecurity <NFSShareSecurityEnum>] [-noAccessHosts <String[]>]
 [-readOnlyHosts <String[]>] [-readWriteHosts <String[]>] [-rootAccessHosts <String[]>] [-append] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Modifies NFS share.
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXEMPLE 1 --------------------------
```
Set-UnityNFSShare -id 'NFSShare_2' -rootAccessHosts Host_20 -append
```

Set NFS Share with id 'NFSShare_2'

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
ID of the NFS share.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -description
NFS share description

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

### -isReadOnly
Indicates whether the NFS share is read-only.
Values are:
- true - NFS share is read-only.
- false - NFS share is read-write.

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

### -defaultAccess
Default access level for all hosts accessing the NFS share.

```yaml
Type: NFSShareDefaultAccessEnum
Parameter Sets: (All)
Aliases: 
Accepted values: NoAccess, ReadOnly, ReadWrite, Root

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -minSecurity
Minimal security level that must be provided by a client to mount the NFS share.

```yaml
Type: NFSShareSecurityEnum
Parameter Sets: (All)
Aliases: 
Accepted values: Sys, Kerberos, KerberosWithIntegrity, KerberosWithEncryption

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -noAccessHosts
Hosts with no access to the NFS share or its snapshots, as defined by the host resource type.

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

### -readOnlyHosts
Hosts with read-only access to the NFS share and its snapshots, as defined by the host resource type.

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

### -readWriteHosts
Hosts with read-write access to the NFS share and its snapshots, as defined by the host resource type.

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

### -rootAccessHosts
Hosts with root access to the NFS share and its snapshots, as defined by the host resource type.

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

### -append
Append Hosts access to existing configuration

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE

## RELATED LINKS

[https://github.com/equelin/Unity-Powershell](https://github.com/equelin/Unity-Powershell)


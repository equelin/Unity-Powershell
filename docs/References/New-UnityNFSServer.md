---
external help file: Unity-Powershell-help.xml
online version: https://github.com/equelin/Unity-Powershell
schema: 2.0.0
---

# New-UnityNFSServer

## SYNOPSIS
Create a new NFS Server.

## SYNTAX

```
New-UnityNFSServer [[-session] <Object>] [-nasServer] <String> [[-hostName] <String>]
 [[-nfsv4Enabled] <Boolean>] [[-isSecureEnabled] <Boolean>] [[-kdcType] <KdcTypeEnum>]
 [[-kdcUsername] <String>] [[-kdcPassword] <String>] [[-isExtendedCredentialsEnabled] <Boolean>]
 [[-credentialsCacheTTL] <DateTime>] [-WhatIf] [-Confirm]
```

## DESCRIPTION
Create a new NFS Server. 
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXEMPLE 1 --------------------------
```
New-UnityNFSServer -nasServer 'nas_15' -hostName 'NFS01'
```

Create a new NFS Server.

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

### -nasServer
ID of the NAS server associated with the NFS server.

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

### -hostName
Host name of the NFS server.
If host name is not specified then SMB server name or NAS server name will be used to auto generate the host name.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -nfsv4Enabled
Indicates whether the NFSv4 is enabled on the NAS server specified in the nasServer attribute.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases: 

Required: False
Position: 4
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -isSecureEnabled
Indicates whether the secure NFS is enabled.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases: 

Required: False
Position: 5
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -kdcType
Type of Kerberos Domain Controller used for secure NFS service.

```yaml
Type: KdcTypeEnum
Parameter Sets: (All)
Aliases: 
Accepted values: Custom, Unix, Windows

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -kdcUsername
Kerberos Domain Controller administrator's name.

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

### -kdcPassword
Kerberos Domain Controller administrator's password.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -isExtendedCredentialsEnabled
Support for more than 16 Unix groups.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases: 

Required: False
Position: 9
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -credentialsCacheTTL
Credential cache refresh timeout.
Resolution is in minutes. 
Default value is 15 minutes.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases: 

Required: False
Position: 10
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


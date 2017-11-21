# Set-UnityNFSServer

## SYNOPSIS
Modifies NFS Server.

## SYNTAX

```
Set-UnityNFSServer [-session <Object>] [-ID] <Object[]> [-hostName <String>] [-nfsv4Enabled <Boolean>]
 [-isSecureEnabled <Boolean>] [-kdcType <KdcTypeEnum>] [-skipUnjoin] [-kdcUsername <String>]
 [-kdcPassword <String>] [-isExtendedCredentialsEnabled <Boolean>] [-credentialsCacheTTL <DateTime>] [-WhatIf]
 [-Confirm]
```

## DESCRIPTION
Modifies NFS Server.
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Set-UnityNFSServer -ID 'default' -Address smtp.example.com
```

Modifies the default NFS Server

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
NFS Server ID or Object.

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

### -hostName
Host name of the NFS server.
If host name is not specified then SMB server name or NAS server name will be used to auto generate the host name.

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

### -nfsv4Enabled
Indicates whether the NFSv4 is enabled on the NAS server specified in the nasServer attribute.

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

### -isSecureEnabled
Indicates whether the secure NFS is enabled.

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

### -kdcType
Type of Kerberos Domain Controller used for secure NFS service.

```yaml
Type: KdcTypeEnum
Parameter Sets: (All)
Aliases: 
Accepted values: Custom, Unix, Windows

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -skipUnjoin
Keep Service Principal Name (SPN) in Kerberos Domain Controller.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: True
Position: Named
Default value: False
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
Position: Named
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
Position: Named
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
Position: Named
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


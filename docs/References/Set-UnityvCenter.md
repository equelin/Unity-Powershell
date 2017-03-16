---
external help file: Unity-Powershell-help.xml
online version: https://github.com/equelin/Unity-Powershell
schema: 2.0.0
---

# Set-UnityvCenter

## SYNOPSIS
Modifies an existing vCenter and optionally discovers any ESXi host managed by that vCenter.

## SYNTAX

### Set (Default)
```
Set-UnityvCenter [-session <Object>] -ID <Object> [-NewAddress <String>] [-NewUsername <String>]
 [-NewPassword <String>] [-Description <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### ImportHosts
```
Set-UnityvCenter [-session <Object>] -ID <Object> -Username <String> -Password <String> [-ImportHosts]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Modifies vCenter servers on the network and optionnaly create a host configuration for multiple ESXi hosts managed by a single vCenter server.
You can't modify vCenter parameters and import hosts in the same command. 
For any discovered vCenters, you can enable or disable access for any ESXi host managed by the vCenter.
After you associate a vCenter server configuration with a VMware datastore, the datastore is available to any ESXi hosts associated with the vCenter host configuration.
The vCenter credentials are stored in the storage system.
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXEMPLE 1 --------------------------
```
Set-UnityvCenter -ID 'mss_1' -Description 'New description'
```

Change the description of the vCenter.

### -------------------------- EXEMPLE 2 --------------------------
```
Set-UnityvCenter -ID 'mss_1' -Username 'administrator@vsphere.local' -Password 'Password#123' -ImportHosts
```

Import hosts associated to the vCenter.

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
vCenter ID or Object.

```yaml
Type: Object
Parameter Sets: (All)
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -NewAddress
The new FQDN or IP address of the VMware vCenter.

```yaml
Type: String
Parameter Sets: Set
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NewUsername
Specifies the new username used to access the VMware vCenter.

```yaml
Type: String
Parameter Sets: Set
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NewPassword
Specifies the new password used to access the VMware vCenter.

```yaml
Type: String
Parameter Sets: Set
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Description
Specifies the new description of the VMware vCenter server.

```yaml
Type: String
Parameter Sets: Set
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Username
Specifies the new username used to access the VMware vCenter.

```yaml
Type: String
Parameter Sets: ImportHosts
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Password
Specifies the new password used to access the VMware vCenter.

```yaml
Type: String
Parameter Sets: ImportHosts
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ImportHosts
Specifies if hosts are automatically imported.

```yaml
Type: SwitchParameter
Parameter Sets: ImportHosts
Aliases: 

Required: True
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


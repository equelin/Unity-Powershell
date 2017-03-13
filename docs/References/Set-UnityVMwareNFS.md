---
external help file: Unity-Powershell-help.xml
online version: https://github.com/equelin/Unity-Powershell
schema: 2.0.0
---

# Set-UnityVMwareNFS

## SYNOPSIS
Modifies filesystem parameters.

## SYNTAX

```
Set-UnityVMwareNFS [-session <Object>] [-ID] <String[]> [-Description <String>] [-snapSchedule <String>]
 [-isSnapSchedulePaused <Boolean>] [-Size <UInt64>] [-hostIOSize <HostIOSizeEnum>]
 [-tieringPolicy <TieringPolicyEnum>] [-defaultAccess <NFSShareDefaultAccessEnum>] [-noAccessHosts <String[]>]
 [-readOnlyHosts <String[]>] [-readWriteHosts <String[]>] [-rootAccessHosts <String[]>] [-append] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Modifies filesystem parameters.
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXEMPLE 1 --------------------------
```
Set-UnityVMwareNFS -ID 'fs_1' -Description 'Modified description'
```

Change the description of the VMware NFS LUN named FS01

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
SetFilesystem

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

### -Description
Filesystem Description

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

### -snapSchedule
ID of a protection schedule to apply to the filesystem

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

### -isSnapSchedulePaused
Is assigned snapshot schedule is paused ?
(Default is false)

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

### -Size
Filesystem Size

```yaml
Type: UInt64
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -hostIOSize
Typical write I/O size from the host to the file system

```yaml
Type: HostIOSizeEnum
Parameter Sets: (All)
Aliases: 
Accepted values: General_8K, Exchange2007, Oracle, SQLServer, VMwareHorizon, SAP, General_16K, General_32K, Exchange2010, Exchange2013, SharePoint, General_64K

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -tieringPolicy
Filesystem tiering policy

```yaml
Type: TieringPolicyEnum
Parameter Sets: (All)
Aliases: 
Accepted values: Autotier_High, Autotier, Highest, Lowest, No_Data_Movement, Mixed

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -defaultAccess
Default access level for all hosts accessing the VMware NFS LUN.

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

### -noAccessHosts
Hosts with no access to the VMware NFS LUN or its snapshots, as defined by the host resource type.

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
Hosts with read-only access to the VMware NFS LUN and its snapshots, as defined by the host resource type.

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
Hosts with read-write access to the VMware NFS LUN and its snapshots, as defined by the host resource type.

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
Hosts with root access to the VMware NFS LUN and its snapshots, as defined by the host resource type.

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


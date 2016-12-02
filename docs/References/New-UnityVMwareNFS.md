---
external help file: Unity-Powershell-help.xml
online version: https://github.com/equelin/Unity-Powershell
schema: 2.0.0
---

# New-UnityVMwareNFS

## SYNOPSIS
Creates a Unity VMware NFS LUN.

## SYNTAX

```
New-UnityVMwareNFS [-session <Object>] [-Name] <String[]> [-Description <String>] [-snapSchedule <String>]
 [-isSnapSchedulePaused <Boolean>] -Pool <String> -nasServer <String> [-isThinEnabled <String>] -Size <UInt64>
 [-hostIOSize <HostIOSizeEnum>] [-defaultAccess <NFSShareDefaultAccessEnum>]
 [-minSecurity <NFSShareSecurityEnum>] [-noAccessHosts <String[]>] [-readOnlyHosts <String[]>]
 [-readWriteHosts <String[]>] [-rootAccessHosts <String[]>] [-tieringPolicy <TieringPolicyEnum>] [-WhatIf]
 [-Confirm]
```

## DESCRIPTION
Creates a Unity VMware NFS LUN.
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXEMPLE 1 --------------------------
```
New-UnityVMwareNFS -Name DATASTORE-NFS-01 -Pool pool_1 -nasServer nas_1 -Size 10GB
```

Create a VMware NFS LUN named 'DATASTORE-NFS-01' on pool 'pool_1' and NAS server 'nas_1' and with a size of '10GB' bytes

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
VMware NFS LUN Name

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
VMware NFS LUN Description

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
ID of a protection schedule to apply to the VMware NFS LUN

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

### -Pool
VMware NFS LUN Pool ID

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

### -nasServer
VMware NFS LUN nasServer ID

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

### -isThinEnabled
Indicates whether to enable thin provisioning for VMware NFS LUN.
Default is $True

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: True
Accept pipeline input: False
Accept wildcard characters: False
```

### -Size
VMware NFS LUN Size

```yaml
Type: UInt64
Parameter Sets: (All)
Aliases: 

Required: True
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -hostIOSize
Typical write I/O size from the host to the VMware NFS LUN

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

### -defaultAccess
Default access level for all hosts accessing the VMware NFS LUN.

```yaml
Type: NFSShareDefaultAccessEnum
Parameter Sets: (All)
Aliases: 
Accepted values: NoAccess, ReadOnly, ReadWrite, Root

Required: False
Position: Named
Default value: NoAccess
Accept pipeline input: False
Accept wildcard characters: False
```

### -minSecurity
Minimal security level that must be provided by a client to mount the VMware NFS LUN.

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

### -tieringPolicy
VMware NFS LUN tiering policy

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


---
external help file: Unity-Powershell-help.xml
online version: https://github.com/equelin/Unity-Powershell
schema: 2.0.0
---

# Set-UnityCIFSShare

## SYNOPSIS
Modifies CIFS share.

## SYNTAX

```
Set-UnityCIFSShare [-session <Object>] [-ID] <String[]> [-description <String>] [-isReadOnly <Boolean>]
 [-isEncryptionEnabled <Boolean>] [-isContinuousAvailabilityEnabled <Boolean>] [-isABEEnabled <Boolean>]
 [-isBranchCacheEnabled <Boolean>] [-offlineAvailability <CifsShareOfflineAvailabilityEnum>] [-umask <String>]
 [-WhatIf] [-Confirm]
```

## DESCRIPTION
Modifies CIFS share.
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXEMPLE 1 --------------------------
```
Set-UnityCIFSShare -ID 'SMBShare_1' -Description 'New description'
```

Modifies the CIFS share with id 'SMBShare_1'

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
ID of the CIFS share.

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
CIFS share description

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
Indicates whether the CIFS share is read-only

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

### -isEncryptionEnabled
Indicates whether CIFS encryption for Server Message Block (SMB) 3.0 is enabled for the CIFS share

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

### -isContinuousAvailabilityEnabled
Indicates whether continuous availability for SMB 3.0 is enabled for the CIFS share

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

### -isABEEnabled
Enumerate file with read access and directories with list access in folder listings

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

### -isBranchCacheEnabled
Branch Cache optimizes traffic between the NAS server and Branch Office Servers

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

### -offlineAvailability
Offline Files store a version of the shared resources on the client computer in the file system cache, 
a reserved portion of disk space, which the client computer can access even when it is disconnected from the network.

```yaml
Type: CifsShareOfflineAvailabilityEnum
Parameter Sets: (All)
Aliases: 
Accepted values: Manual, Documents, Programs, None, Invalid

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -umask
The default UNIX umask for new files created on the share.

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


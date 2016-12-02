---
external help file: Unity-Powershell-help.xml
online version: https://github.com/equelin/Unity-Powershell
schema: 2.0.0
---

# New-UnityCIFSServer

## SYNOPSIS
Create an SMB/CIFS server.

## SYNTAX

### AD (Default)
```
New-UnityCIFSServer [-session <Object>] [[-Name] <String[]>] -nasServer <String> [-netbiosName <String>]
 [-Description <String>] [-domain <String>] [-organizationalUnit <String>] [-domainUsername <String>]
 [-domainPassword <String>] [-reuseComputerAccount <Boolean>] [-interfaces <String[]>] [-WhatIf] [-Confirm]
```

### Workgroup
```
New-UnityCIFSServer [-session <Object>] [[-Name] <String[]>] -nasServer <String> [-netbiosName <String>]
 [-Description <String>] [-workgroup <String>] [-localAdminPassword <String>] [-interfaces <String[]>]
 [-WhatIf] [-Confirm]
```

## DESCRIPTION
Create an SMB/CIFS server.
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXEMPLE 1 --------------------------
```
New-UnityCIFSServer -Name CIFS01 -nasServer 'nas_6' -domain 'example.com' -domainUsername 'administrator' -domainPassword 'Password#123' -interfaces 'if_1'
```

Create CIFS Server named 'CIFS01'

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
User friendly, descriptive name of SMB server.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -nasServer
ID of the NAS server to which the SMB server belongs.

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

### -netbiosName
Computer name of the SMB server in Windows network.

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

### -Description
Description of the SMB server.

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

### -domain
Domain name where SMB server is registered in Active Directory, if applicable.

```yaml
Type: String
Parameter Sets: AD
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -organizationalUnit
LDAP organizational unit of SMB server in Active Directory, if applicable.

```yaml
Type: String
Parameter Sets: AD
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -domainUsername
Active Directory domain user name.

```yaml
Type: String
Parameter Sets: AD
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -domainPassword
Active Directory domain password.

```yaml
Type: String
Parameter Sets: AD
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -reuseComputerAccount
Reuse existing SMB server account in the Active Directory.

```yaml
Type: Boolean
Parameter Sets: AD
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -workgroup
Standalone SMB server workgroup.

```yaml
Type: String
Parameter Sets: Workgroup
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -localAdminPassword
Standalone SMB server administrator password.

```yaml
Type: String
Parameter Sets: Workgroup
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -interfaces
List of file IP interfaces that service CIFS protocol of SMB server.

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


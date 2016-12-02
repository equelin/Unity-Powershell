---
external help file: Unity-Powershell-help.xml
online version: https://github.com/equelin/Unity-Powershell
schema: 2.0.0
---

# Remove-UnityCIFSServer

## SYNOPSIS
Delete a Cifs Server.

## SYNTAX

```
Remove-UnityCIFSServer [-session <Object>] [-ID] <Object> [-skipUnjoin <Boolean>] [-domainUsername <String>]
 [-domainPassword <String>] [-WhatIf] [-Confirm]
```

## DESCRIPTION
Delete a Cifs Server.
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXEMPLE 1 --------------------------
```
Remove-UnityCifsServer -ID 'cifs_1'
```

Delete the Cifs Server with ID 'cifs_1'

### -------------------------- EXEMPLE 2 --------------------------
```
Get-UnityCifsServer -Name 'CIFS01' | Remove-UnityCifsServer
```

Delete the Cifs Server named 'CIFS01'.
The Cifs Server's informations are provided by the Get-UnityNasServer through the pipeline.

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
CIFS Server ID or Object.

```yaml
Type: Object
Parameter Sets: (All)
Aliases: 

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -skipUnjoin
Keep SMB server account unjoined in Active Directory after deletion.

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

### -domainUsername
Username for unjoin.

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

### -domainPassword
Password for unjoin.

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


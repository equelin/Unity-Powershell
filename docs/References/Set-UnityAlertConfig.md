---
external help file: Unity-Powershell-help.xml
online version: https://github.com/equelin/Unity-Powershell
schema: 2.0.0
---

# Set-UnityAlertConfig

## SYNOPSIS
Modifies Alert Config.

## SYNTAX

```
Set-UnityAlertConfig [-session <Object>] [[-ID] <String[]>] [-alertLocale <LocaleEnum>]
 [-isThresholdAlertsEnabled <Boolean>] [-minEmailNotificationSeverity <SeverityEnum>]
 [-minSNMPTrapNotificationSeverity <SeverityEnum>] [-destinationEmails <String[]>] [-WhatIf] [-Confirm]
```

## DESCRIPTION
Modifies Alert Config.
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXEMPLE 1 --------------------------
```
Set-UnityAlertConfig -destinationEmails 'mail@example.com'
```

Modifies the default Alert Config

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
Config ALert ID or Object.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 

Required: False
Position: 1
Default value: 0
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -alertLocale
Language in which the system sends email alerts.

```yaml
Type: LocaleEnum
Parameter Sets: (All)
Aliases: 
Accepted values: en_US, es_AR, de_DE, fr_FR, it_IT, ja_JP, ko_KR, pt_BR, ru_RU, zh_CN

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -isThresholdAlertsEnabled
Whether pool space usage related alerts will be sent.

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

### -minEmailNotificationSeverity
Minimum severity level for email alerts.

```yaml
Type: SeverityEnum
Parameter Sets: (All)
Aliases: 
Accepted values: EMERGENCY, ALERT, CRITICAL, ERROR, WARNING, NOTICE, INFO, DEBUG, OK

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -minSNMPTrapNotificationSeverity
Minimum severity level for SNMP trap alerts.

```yaml
Type: SeverityEnum
Parameter Sets: (All)
Aliases: 
Accepted values: EMERGENCY, ALERT, CRITICAL, ERROR, WARNING, NOTICE, INFO, DEBUG, OK

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -destinationEmails
List of emails to receive alert notifications.

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


# Set-UnitySnapSchedule

## SYNOPSIS
Modifies snapshot schedule parameters.

## SYNTAX

### addRules (Default)
```
Set-UnitySnapSchedule [-session <Object>] [-ID] <Object[]> [-addRules] -type <ScheduleTypeEnum>
 [-minute <UInt32>] [-hours <UInt32[]>] [-daysOfWeek <DayOfWeekEnum[]>] [-daysOfMonth <UInt32>]
 [-interval <UInt32>] [-isAutoDelete <Boolean>] [-retentionTime <UInt64>]
 [-accessType <FilesystemSnapAccessTypeEnum>] [-WhatIf] [-Confirm]
```

### removeRuleIds
```
Set-UnitySnapSchedule [-session <Object>] [-ID] <Object[]> -removeRuleIds <String[]> [-WhatIf] [-Confirm]
```

## DESCRIPTION
Modifies snapshot schedule parameters.
You can add or delete rules.
Rules can be added one at a time.
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Set-UnitySnapSchedule -ID 'snapSch_6' -addRules -Type N_HOURS_AT_MM -Interval 12 -Minutes 30
```

Add rule to snapshot schedule with ID 'snapSch_6'.
Snap every 12 hours, at 30 minutes past the hour.

### -------------------------- EXAMPLE 2 --------------------------
```
Set-UnitySnapSchedule -ID 'snapSch_6' -removeRuleIds 'SchedRule_11'
```

Remove rule ID 'SchedRule_11' to snapshot schedule with ID 'snapSch_6'.

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
ID of the snapshot Schedule or snapshot Schedule Object.

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

### -addRules
Rules to add to the snapshot schedule.

```yaml
Type: SwitchParameter
Parameter Sets: addRules
Aliases: 

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -type
Type of snapshot schedule rule.
Values are:
- N_HOURS_AT_MM: Snap every \<interval\> hours, at \<minutes\> past the hour.
Supported parameters: interval (required), minutes (optional, default 0). 
- DAY_AT_HHMM: Specify a list of \<hour\[,...\]\> to snap one or more times each day at \<minutes\> past the hour.
Supported parameters: hours (at least one required), minutes (optional).
 
- N_DAYS_AT_HHMM: Snap every \<interval\> days at the time \<hours\>:\<minutes\>.
Supported Parameters: interval (required), hours (optional, exactly one), minutes (optional). 
- SELDAYS_AT_HHMM: Snap on the selected \<daysOfWeek\>, at the time \<hours\>:\<minutes\>.
Supported parameters: daysOfWeek (at least one required), hours (optional, default 0), minutes (optional, default 0). 
- NTH_DAYOFMONTH_AT_HHMM: Snap on the selected \<daysOfMonth\>, at the time \<hours\>:\<minutes\>.
Supported parameters: daysOfMonth (at least one required), hours (optional, default 0), minutes (optional, default 0).

```yaml
Type: ScheduleTypeEnum
Parameter Sets: addRules
Aliases: 
Accepted values: N_HOURS_AT_MM, DAY_AT_HHMM, N_DAYS_AT_HHMM, SELDAYS_AT_HHMM, NTH_DAYOFMONTH_AT_HHMM, UNSUPPORTED

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -minute
Minute frequency for the snapshot schedule rule.

```yaml
Type: UInt32
Parameter Sets: addRules
Aliases: 

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -hours
Hourly frequency for the snapshot schedule rule.

```yaml
Type: UInt32[]
Parameter Sets: addRules
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -daysOfWeek
Days of the week for which the snapshot schedule rule applies.

```yaml
Type: DayOfWeekEnum[]
Parameter Sets: addRules
Aliases: 
Accepted values: Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -daysOfMonth
Days of the month for which the snapshot schedule rule applies.

```yaml
Type: UInt32
Parameter Sets: addRules
Aliases: 

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -interval
Number of days or hours between snaps, depending on the rule type.

```yaml
Type: UInt32
Parameter Sets: addRules
Aliases: 

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -isAutoDelete
Indicates whether the system can automatically delete the snapshot based on pool automatic-deletion thresholds.
Values are:
- $True: System can delete the snapshot based on pool automatic-deletion thresholds.
- $False: System cannot delete the snapshot based on pool automatic-deletion thresholds.

```yaml
Type: Boolean
Parameter Sets: addRules
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -retentionTime
(Applies when the value of the isAutoDelete attribute is false.) Period of time in seconds for which to keep the snapshot.

```yaml
Type: UInt64
Parameter Sets: addRules
Aliases: 

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -accessType
For a file system or VMware NFS datastore snapshot schedule, indicates whether the snapshot created by the schedule has checkpoint or protocol type access

```yaml
Type: FilesystemSnapAccessTypeEnum
Parameter Sets: addRules
Aliases: 
Accepted values: Checkpoint, Protocol

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -removeRuleIds
ID of the rules to remove from the snapshot schedule.

```yaml
Type: String[]
Parameter Sets: removeRuleIds
Aliases: 

Required: True
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


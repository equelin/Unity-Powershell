# Set-UnityNTPServer

## SYNOPSIS
Modifies NTP Servers parameters.

## SYNTAX

```
Set-UnityNTPServer [-session <Object>] [-Addresses] <String[]> [-rebootPrivilege <RebootPrivilegeEnum>]
 [-WhatIf] [-Confirm]
```

## DESCRIPTION
Modifies NTP Servers parameters.
You can configure a total of four NTP server addresses for the system. 
All NTP server addresses are grouped into a single NTP server record. 
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXEMPLE 1 --------------------------
```
Set-UnityNTPServer -Addresses '192.168.0.1','192.168.0.2'
```

replace the exsting address list for this NTP server with this new list.

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

### -Addresses
List of NTP server IP addresses.

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

### -rebootPrivilege
Indicates whether a system reboot of the NTP server is required for setting the system time.

```yaml
Type: RebootPrivilegeEnum
Parameter Sets: (All)
Aliases: 
Accepted values: No_Reboot_Allowed, Reboot_Allowed, DU_Allowed

Required: False
Position: Named
Default value: No_Reboot_Allowed
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


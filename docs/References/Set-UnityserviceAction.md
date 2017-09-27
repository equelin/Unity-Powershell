# Set-UnityserviceAction

## SYNOPSIS
Services the system.

## SYNTAX

### changeSSHStatus (Default)
```
Set-UnityserviceAction [-session <Object>] [-Async] [-changeSSHStatus] -currentPassword <String> [-WhatIf]
 [-Confirm]
```

### dataCollection
```
Set-UnityserviceAction [-session <Object>] [-Async] [-dataCollection] [-includePrivateData]
 [-dataCollectionProfile <DataCollectionProfileEnum>] [-WhatIf] [-Confirm]
```

## DESCRIPTION
Services the system.
Possible actions: 
  - Collect Service Information (dataCollection): Collect information about the storage system and save it to a file.
Your service provider can use the collected information to analyze the storage system. 
  - Save Configuration (configCapture): Save details about the configuration settings on the storage system to a file.
Your service provider can use this file to assist you with reconfiguring your system after a major system failure or a system reinitialization. 
  - Restart Management Software (restartMGT): Restart the management software to resolve connection problems between the system and Unisphere. 
  - Reinitialize (reinitialize): Reset the storage system to the original factory settings.
Both SPs must be installed and operating normally be in Service Mode. 
  - Change Service Password (changeServicePassword): Change the service password for accessing the Service System page. 
  - Shut Down System (shutdownSystem): The system shut down and power cycle procedures will attempt to resolve problems with your storage system that could not be resolved by rebooting or reimaging the SP. 
  - Disable SSH/Enable SSH (changeSSHStatus): Disable the Secure Shell (SSH) protocol to block SSH access to the system, or enable the Secure Shell (SSH) protocol to enable access to the system. 
  - Enter Service Mode (enterServiceModeSPA, enterServiceModeSPB): Stop I/O on the SP so that the SP can enter service mode safely. 
  - Reboot (rebootSPA, rebootSPB): Reboot the selected SP.
Use this service action to attempt to resolve minor problems related to system software or SP hardware components. 
  - Reimage (rebootSPA, rebootSPB): Reimage the selected SP.
Reimaging analyzes the system software on the SP and attempts to correct any problems automatically. 
  - Reset and Hold(resetAndHoldSPA, resetAndHoldSPB): Reset and hold the selected SP.
Use this service task to attempt to reset and hold the SP, so that users can replace the faulty IoModule(s) on that SP.
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXEMPLE 1 --------------------------
```
Set-UnityserviceAction -changeSSHStatus
```

Change the SSH status depending of the current state

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

### -Async
EMC Unity Session

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

### -dataCollection
Collect information about the storage system and save it to a file.

```yaml
Type: SwitchParameter
Parameter Sets: dataCollection
Aliases: 

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -includePrivateData
Indicates whether the capture includes private data when performing the Save Configuration (configCapture) service action.

```yaml
Type: SwitchParameter
Parameter Sets: dataCollection
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -dataCollectionProfile
The profile used to collect service information.

```yaml
Type: DataCollectionProfileEnum
Parameter Sets: dataCollection
Aliases: 
Accepted values: Default, Performance_Assessment, Performance_Trace, Other

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -changeSSHStatus
Disable the Secure Shell (SSH) protocol to block SSH access to the system, or enable the Secure Shell (SSH) protocol to enable access to the system.

```yaml
Type: SwitchParameter
Parameter Sets: changeSSHStatus
Aliases: 

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -currentPassword
Current password of the service user.
needed when performing the Change Service Password (changeServicePassword) service action.

```yaml
Type: String
Parameter Sets: changeSSHStatus
Aliases: 

Required: True
Position: Named
Default value: None
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

## INPUTS

## OUTPUTS

## NOTES
Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE

## RELATED LINKS

[https://github.com/equelin/Unity-Powershell](https://github.com/equelin/Unity-Powershell)


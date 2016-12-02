---
external help file: Unity-Powershell-help.xml
online version: https://github.com/equelin/Unity-Powershell
schema: 2.0.0
---

# Remove-UnityNASServer

## SYNOPSIS
Delete a Nas Server.

## SYNTAX

```
Remove-UnityNASServer [-session <Object>] [-ID] <Object> [-WhatIf] [-Confirm]
```

## DESCRIPTION
Delete a Nas Server.
Before you can delete a NAS server, you must first delete all storage resources associated with it.
Deleting a NAS server removes everything configured on the NAS server, but does not delete the storage resources that use it. 
You cannot delete a NAS server while it has any associated storage resources.
After the storage resources are deleted, the files and folders inside them cannot be restored from snapshots.
Back up the data from the storage resources before deleting them from the system.

You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXEMPLE 1 --------------------------
```
Remove-UnityNasServer -ID 'nas_6'
```

Delete the Nas Server with ID 'nas_6'

### -------------------------- EXEMPLE 2 --------------------------
```
Get-UnityNasServer -Name 'NAS01' | Remove-UnityNasServer
```

Delete the Nas Server named 'NAS01'.
The NAS server's informations are provided by the Get-UnityNasServer through the pipeline.

## PARAMETERS

### -session
Specifies an UnitySession Object.

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
Specifies the NAS server ID or Object.

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


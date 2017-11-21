# Invoke-UnityRefreshVMwareLUNThinClone

## SYNOPSIS
Refresh a VMwareLUN thin clone.

## SYNTAX

```
Invoke-UnityRefreshVMwareLUNThinClone [[-session] <Object>] [-VMwareLUN] <Object> [-snap] <Object>
 [-copyName] <String> [-force] [-WhatIf] [-Confirm]
```

## DESCRIPTION
Refresh a VMwareLUN thin clone.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
$Snap = Get-UnityVMwareLUN -Name 'VMwareLUN01' | New-UnitySnap -isAutoDelete:$false
```

$ThinClone = Get-UnityVMwareLUN -Name 'VMwareLUN01-ThinClone'
Invoke-UnityRefreshVMwareLUNThinClone -VMwareLUN $ThinClone.id -snap $snap.id -copyName 'VMwareLUN01-Snapshot'

## PARAMETERS

### -session
Specify an UnitySession Object.

```yaml
Type: Object
Parameter Sets: (All)
Aliases: 

Required: False
Position: 1
Default value: ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true})
Accept pipeline input: False
Accept wildcard characters: False
```

### -VMwareLUN
VMwareLUN id or Object

```yaml
Type: Object
Parameter Sets: (All)
Aliases: 

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -snap
The reference to the new source snapshot object.
The new source snapshot may be any snap of this Thin Clone's base storage resource, including the current one.

```yaml
Type: Object
Parameter Sets: (All)
Aliases: 

Required: True
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -copyName
Name of the snapshot copy created before the refresh operation occurs.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -force
When set, the refresh operation will proceed even if host access is configured on the storage resource.

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

## INPUTS

## OUTPUTS

## NOTES
Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE

## RELATED LINKS

[https://github.com/equelin/Unity-Powershell](https://github.com/equelin/Unity-Powershell)


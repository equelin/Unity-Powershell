# New-UnityVMwareLUN

## SYNOPSIS
Creates a Unity VMware block LUN.

## SYNTAX

```
New-UnityVMwareLUN [-session <Object>] [-Name] <String[]> [-Description <String>] -Pool <String> -Size <UInt64>
 [-host <String[]>] [-accessMask <HostLUNAccessEnum>] [-isThinEnabled <Boolean>]
 [-fastVPParameters <TieringPolicyEnum>] [-isCompressionEnabled <Boolean>] [-snapSchedule <String>]
 [-isSnapSchedulePaused <Boolean>] [-WhatIf] [-Confirm]
```

## DESCRIPTION
Creates a Unity VMware block LUN.
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
New-UnityVMwareLUN -Name 'DATASTORE01' -Pool 'pool_1' -Size 10GB -host 'Host_12' -accessMask 'Production'
```

Create LUN named 'DATASTORE01' on pool 'pool_1' and with a size of '10GB', grant production access to 'Host_12'

### -------------------------- EXAMPLE 2 --------------------------
```
for($i=1; $i -le 10; $i++){New-UnityVMwareLUN -Name "DATASTORE0$i" -Size 2TB -Pool 'pool_1' -host (Get-UnityHost).id}
```

Create 10 datastores on pool 'pool_1' and with a size of '2TB', grant production access to all existing hosts.

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
Name of the VMware VMFS datastore unique to the system.

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
Description of the VMware VMFS datastore.

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

### -Pool
Pool ID

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

### -Size
LUN Size.

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

### -host
List of host to grant access to LUN.

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

### -accessMask
Host access mask.
Might be:
- NoAccess: No access. 
- Production: Access to production LUNs only. 
- Snapshot: Access to LUN snapshots only. 
- Both: Access to both production LUNs and their snapshots.

```yaml
Type: HostLUNAccessEnum
Parameter Sets: (All)
Aliases: 
Accepted values: NoAccess, Production, Snapshot, Both, Mixed

Required: False
Position: Named
Default value: Production
Accept pipeline input: False
Accept wildcard characters: False
```

### -isThinEnabled
Is Thin enabled?
(Default is true)

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: True
Accept pipeline input: False
Accept wildcard characters: False
```

### -fastVPParameters
FAST VP settings for the storage resource

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

### -isCompressionEnabled
Indicates whether to enable inline compression for the LUN.
Default is True on supported arrays

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

### -snapSchedule
Snapshot schedule assigned to the storage resource

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
Indicates whether the assigned snapshot schedule is paused.

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


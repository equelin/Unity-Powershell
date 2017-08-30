# Get-Unityjob

## SYNOPSIS
Information about the jobs in the storage system.
\<br/\> \<br/\> A job represents one management request, it consists of a series of tasks.
\<br/\> A job could also contain a series of primitive REST API POST requests, each of which maps to a task in the job.
Such job is known as "batch request job".
\<br/\> Client can query the job instance to track its progress, results, and details of each task.
\<br/\> \<br/\> When a job is failed, the system might leave hehind unneeded resources that consume space.
You can manually delete any resources that were created for the failed job.
\<br/\>

## SYNTAX

### Name (Default)
```
Get-Unityjob [-session <Object>]
```

### ID
```
Get-Unityjob [-session <Object>] [-ID <String[]>]
```

## DESCRIPTION
Information about the jobs in the storage system.
\<br/\> \<br/\> A job represents one management request, it consists of a series of tasks.
\<br/\> A job could also contain a series of primitive REST API POST requests, each of which maps to a task in the job.
Such job is known as "batch request job".
\<br/\> Client can query the job instance to track its progress, results, and details of each task.
\<br/\> \<br/\> When a job is failed, the system might leave hehind unneeded resources that consume space.
You can manually delete any resources that were created for the failed job.
\<br/\>  
You need to have an active session with the array.

## EXAMPLES

### -------------------------- EXEMPLE 1 --------------------------
```
Get-Unityjob
```

Retrieve information about all Unityjob

### -------------------------- EXEMPLE 2 --------------------------
```
Get-Unityjob -ID 'id01'
```

Retrieves information about a specific Unityjob

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
Specifies the object ID.

```yaml
Type: String[]
Parameter Sets: ID
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES
Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE

## RELATED LINKS

[https://github.com/equelin/Unity-Powershell](https://github.com/equelin/Unity-Powershell)


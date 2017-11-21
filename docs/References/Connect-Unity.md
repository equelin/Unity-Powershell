# Connect-Unity

## SYNOPSIS
Connects to an EMC Unity Array

## SYNTAX

### ByServer (Default)
```
Connect-Unity [-Server] <String[]> [-Username <String>] [-Password <SecureString>]
 [-Credentials <PSCredential>] [-TrustAllCerts <Boolean>]
```

### BySession
```
Connect-Unity -Session <Object> [-Username <String>] [-Password <SecureString>] [-Credentials <PSCredential>]
 [-TrustAllCerts <Boolean>]
```

## DESCRIPTION
Connects to an EMC Unity Array.
This cmdlet starts a new session with an EMC Unity Array using the specified parameters.
When you attempt to connect to an array, the array checks for valid certificates.
To avoid this use the -TrusAllCerts param.
You can have more than one connection to the same array.
To disconnect from an array, you need to close all active connections to this server using the Disconnect-Unity cmdlet.
Every new connection is stored in the $global:DefaultUnitySession array.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Connect-Unity -Server 192.0.2.1
```

Connects to the array with the IP 192.0.2.1

### -------------------------- EXAMPLE 2 --------------------------
```
Connect-Unity -Server 192.0.2.1 -TrustAllCerts $false
```

Connects to the array with the IP 192.0.2.1 and don't accept unknown certificates.

### -------------------------- EXAMPLE 3 --------------------------
```
Connect-Unity -Server 192.0.2.1,192.0.2.2
```

Connects to the arrays with the IP 192.0.2.1 and 192.0.2.2.
The same user and password is used.

### -------------------------- EXAMPLE 4 --------------------------
```
$IP = '192.0.2.1'
```

$Username = 'admin'
$Password = 'Password123#'
$Secpasswd = ConvertTo-SecureString $Password -AsPlainText -Force
$Credentials = New-Object System.Management.Automation.PSCredential($Username,$secpasswd)
Connect-Unity -Server $IP -Credentials $Credentials

Connects to the arrays with the IP 192.0.2.1 and using powershell credentials

## PARAMETERS

### -Server
IP or FQDN of the Unity array.

```yaml
Type: String[]
Parameter Sets: ByServer
Aliases: 

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Session
Specifies an UnitySession Object.

```yaml
Type: Object
Parameter Sets: BySession
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Username
Specifies the username.

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

### -Password
Specifies the password.
It as to be a powershell's secure string.

```yaml
Type: SecureString
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credentials
Credentials object of type \[System.Management.Automation.PSCredential\]

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TrustAllCerts
Specifies if

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

## INPUTS

## OUTPUTS

## NOTES
Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE

## RELATED LINKS

[https://github.com/equelin/Unity-Powershell](https://github.com/equelin/Unity-Powershell)


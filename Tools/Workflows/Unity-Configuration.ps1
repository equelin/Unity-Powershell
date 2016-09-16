#require Unity-Powershell

[CmdletBinding()]
Param ()

$Server = '10.44.10.112'
$UnityUsername = 'admin'
$UnityPassword = 'Password123#'

#System

$DNS = '10.44.10.101'
$DefaultSMTP = 'mail.example.com'
$NTP = '10.44.10.101'

$UserName = 'User01'
$UserPassword = 'Password123#'
$UserRole = 'administrator'

#Pool

$PoolVdiskID = 'vdisk_3'
$PoolVdiskTier = 'Performance'
$PoolName = 'POOL01'

#VMwareLUN

$VMwareLUNName = 'DATASTORE01'
$VMwareLUNSize = 10GB

#VMwareLUN

$LUNName = 'LUN01'
$LUNSize = 10GB

#iSCSI Portal

$ethernetPort = 'spa_eth0'
$ipAddress = '10.44.40.252'
$netmask = '255.255.255.0'

# NAS Server

$NasServerName = 'NAS01'
$homeSP = 'spa'

# File Interface

$FileInterfaceipPort = 'spa_eth0'
$FileInterfaceipAddress = '10.44.40.253'
$FileInterfacenetmask = '255.255.0.0'
$FileInterfacegateway = '10.44.1.254'

# File DNS Server
$FileDNSDomainName = 'example.local'
$FileDNSAddress = '10.44.10.101'

# CIFS Server
$CIFSServerName = 'CIFS01'
$CIFSServerdomainUsername = 'administrator'
$CIFSServerdomainPassword = 'Password123#'

# Filesystem
$FilesystemName = 'FS01'
$FilesystemsupportedProtocols = 'CIFS'
$FilesystemSize = 10GB

# CIFS Share
$CIFSShareName = 'SHARE01'
$CIFSSharePath = '/'

######## SCRIPT ###########

Write-Host "Connecting to Unity" -ForegroundColor 'magenta'

$UnitySecurePassword = $UnityPassword | ConvertTo-SecureString -AsPlainText -Force

Write-Host "[+]    Connecting to Unity $Server" -ForegroundColor 'Green'
$Session = Connect-Unity -Server $server -Username $UnityUsername -Password $UnitySecurePassword

Write-Host "Configuring the system" -ForegroundColor 'magenta'

Write-Host "[+]    Accepting EULA" -ForegroundColor 'Green'
Set-UnitySystem -Session $Session -ID '0' -isEULAAccepted $True -Confirm:$false | Out-Null

Write-Host "[+]    Creating user $UserName" -ForegroundColor 'Green'
New-UnityUser -Session $Session -Name $UserName -Password $UserPassword -Role $UserRole -Confirm:$false | Out-Null

Write-Host "[+]    Setting DNS Server addresses $DNS" -ForegroundColor 'Green'
Set-UnityDNSServer -Session $Session -Addresses $DNS -Confirm:$false | Out-Null

Write-Host "[+]    Setting NTP Server addresses $NTP" -ForegroundColor 'Green'
Set-UnityNTPServer -Session $Session -Addresses $NTP -Confirm:$false | Out-Null

Write-Host "[+]    Setting SMTP Server addresses $DefaultSMTP" -ForegroundColor 'Green'
New-UnitySMTPServer -Session $Session -address $DefaultSMTP -type Default -Confirm:$false | Out-Null

Write-Host "Configuring storage" -ForegroundColor 'magenta'

Write-Host "[+]    Creating Pool $PoolName" -ForegroundColor 'Green'
$Pool = New-UnityPool -Session $Session -Name $PoolName -virtualDisk @{"id"=$PoolVdiskID;"tier"=$PoolVdiskTier} -Confirm:$false

Write-Host "[+]    Creating VMware LUN $VMwareLUNName" -ForegroundColor 'Green'
New-UnityVMwareLUN -Session $Session -Name $VMwareLUNName -Size $VMwareLUNSize -Pool $Pool.id -Confirm:$false | Out-Null

Write-Host "[+]    Creating LUN $LUNName" -ForegroundColor 'Green'
New-UnityLUN -Session $Session -Name $LUNName -Size $LUNSize -Pool $Pool.id -Confirm:$false | Out-Null

Write-Host "[+]    Creating iSCSI Portal on $ethernetPort with IP $ipAddress" -ForegroundColor 'Green'
New-UnityIscsiPortal -Session $Session -ethernetPort $ethernetPort -ipAddress $ipAddress -netmask $netmask -Confirm:$false | Out-Null

Write-Host "Configuring NAS" -ForegroundColor 'magenta'

Write-Host "[+]    Creating NAS Server $NasServerName" -ForegroundColor 'Green'
$NasServer = New-UnityNasServer -Session $Session -Name $NasServerName -Pool $Pool.id -homeSP $homeSP -Confirm:$false

Write-Host "[+]    Creating File Interface on $FileInterfaceipPort with IP $FileInterfaceipAddress" -ForegroundColor 'Green'
$FileInterface = New-UnityFileInterface -Session $Session -ipPort $FileInterfaceipPort -nasServer $NasServer.id -ipAddress $FileInterfaceipAddress -netmask $FileInterfacenetmask -gateway $FileInterfacegateway -Confirm:$false

Write-Host "[+]    Creating File DNS with address $FileDNSAddress" -ForegroundColor 'Green'
New-UnityFileDNSServer -Session $Session -nasServer $NasServer.id -domain $FileDNSDomainName -addresses $FileDNSAddress -Confirm:$false | Out-Null

Write-Host "[+]    Creating File CIFS Server $CIFSServerName" -ForegroundColor 'Green'
$CIFSServer = New-UnityCIFSServer -Session $Session -Name $CIFSServerName -nasServer $NasServer.id -domain $FileDNSDomainName -domainUsername $CIFSServerdomainUsername -domainPassword $CIFSServerdomainPassword -interfaces $FileInterface.id -Confirm:$false

Write-Host "[+]    Creating Filesystem $FilesystemName" -ForegroundColor 'Green'
$Filesystem = New-UnityFilesystem -Session $Session -Name $FilesystemName -Pool $Pool.id -Size $FilesystemSize -nasServer $NasServer.id -supportedProtocols $FilesystemsupportedProtocols -Confirm:$false

Write-Host "[+]    Creating CIFS Share $CIFSShareName" -ForegroundColor 'Green'
New-UnityCIFSShare -Session $Session -Filesystem $Filesystem.id -Name $CIFSShareName -path $CIFSSharePath -cifsServer $CIFSServer.id -Confirm:$false | Out-Null

Write-Host "Disconnecting from Unity" -ForegroundColor 'magenta'

Write-Host "[+]    Disconnecting from Unity $Server" -ForegroundColor 'Green'
Disconnect-Unity -Session $Session -Confirm:$false | Out-Null

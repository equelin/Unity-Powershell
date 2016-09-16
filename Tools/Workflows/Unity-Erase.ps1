#require Unity-Powershell

[CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
Param ()

##### Variables ######

$Server = '10.44.10.112'
$UnityUsername = 'admin'
$UnityPassword = 'Password123#'

$domainUsername = 'administrator'
$domainPassword = 'Password123#'

##### Script ######

Write-Warning -Message 'You are about to erase all your data !'

If ($pscmdlet.ShouldProcess($Server,"Deleting all data")) {
    Write-Host "Connecting to Unity" -ForegroundColor 'magenta'

    $UnitySecurePassword = $UnityPassword | ConvertTo-SecureString -AsPlainText -Force

    Write-Host "[+]    Connecting to Unity $Server" -ForegroundColor 'Green'
    $Session = Connect-Unity -Server $server -Username $UnityUsername -Password $UnitySecurePassword

    Write-Host "Deleting NAS configuration" -ForegroundColor 'magenta'

    Write-Host "[-]    Deleting CIFS Share" -ForegroundColor 'Red'
    Get-UnityCIFSShare -Session $Session | Remove-UnityCIFSShare -Session $Session -Confirm:$false

    Write-Host "[-]    Deleting Filesystem" -ForegroundColor 'Red'
    Get-UnityFilesystem -Session $Session | Remove-UnityFilesystem -Session $Session -Confirm:$false

    Write-Host "[-]    Deleting CIFS Server" -ForegroundColor 'Red'
    Get-UnityCIFSServer -Session $Session | Remove-UnityCIFSServer -Session $Session -domainUsername $domainUsername -domainPassword $domainPassword -Confirm:$false

    Write-Host "[-]    Deleting File DNS Server" -ForegroundColor 'Red'
    Get-UnityFileDNSServer -Session $Session | Remove-UnityFileDNSServer -Session $Session -Confirm:$false

    Write-Host "[-]    Deleting File Interface" -ForegroundColor 'Red'
    Get-UnityFileInterface -Session $Session | Remove-UnityFileInterface -Session $Session -Confirm:$false

    Write-Host "[-]    Deleting NAS Server" -ForegroundColor 'Red'
    Get-UnityNasServer -Session $Session | Remove-UnityNasServer -Session $Session -Confirm:$false

    Write-Host "Deleting Host configuration" -ForegroundColor 'magenta'

    Write-Host "[-]    Deleting vCenter" -ForegroundColor 'Red'
    Get-UnityvCenter -Session $Session | Remove-UnityvCenter -Session $Session -Confirm:$false

    Write-Host "[-]    Deleting Hosts" -ForegroundColor 'Red'
    Get-UnityHost -Session $Session | Remove-UnityHost -Session $Session -Confirm:$false

    Write-Host "Deleting Storage configuration" -ForegroundColor 'magenta'

    Write-Host "[-]    Deleting iSCSI Portal" -ForegroundColor 'Red'
    Get-UnityIscsiPortal -Session $Session | Remove-UnityIscsiPortal -Session $Session -Confirm:$false

    Write-Host "[-]    Deleting VMware LUN" -ForegroundColor 'Red'
    Get-UnityVMwareLUN -Session $Session | Remove-UnityVMwareLUN -Session $Session -Confirm:$false

    Write-Host "[-]    Deleting LUN" -ForegroundColor 'Red'
    Get-UnityLUN -Session $Session | Remove-UnityLUN -Session $Session -Confirm:$false

    Write-Host "[-]    Deleting Pool" -ForegroundColor 'Red'
    Get-UnityPool -Session $Session | Remove-UnityPool -Session $Session -Confirm:$false

    Write-Host "Deleting system configuration" -ForegroundColor 'magenta'

    Write-Host "[-]    Deleting SMTP Server" -ForegroundColor 'Red'
    Get-UnitySMTPServer -Session $Session | Remove-UnitySMTPServer -Session $Session -Confirm:$false

    Write-Host "[-]    Deleting Users" -ForegroundColor 'Red'
    Get-UnityUser -Session $Session | where-object {$_.Name -ne 'admin'} | Remove-UnityUser -Session $Session -Confirm:$false

    Write-Host "Disconnecting from Unity" -ForegroundColor 'magenta'

    Write-Host "[+]    Disconnecting from Unity $Server" -ForegroundColor 'Green'
    Disconnect-Unity -Session $Session -Confirm:$false | Out-Null
}


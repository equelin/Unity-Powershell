$here = Split-Path -Parent $MyInvocation.MyCommand.Path

#Get information from the module manifest
$manifestPath = "$here\..\..\Unity-Powershell\Unity-Powershell.psd1"
$manifest = Test-ModuleManifest -Path $manifestPath

#Test if a Unity-Powershell module is already loaded
$Module = Get-Module -Name 'Unity-Powershell' -ErrorAction SilentlyContinue

#Load the module if needed
If ($module) {
    If ($Module.Version -ne $manifest.version) {
        Remove-Module $Module
        Import-Module "$here\..\..\Unity-Powershell" -Version $manifest.version -force
    }
} else {
    Import-Module "$here\..\..\Unity-Powershell" -Version $manifest.version -force
}

Describe -Name "Unit testing New-UnityObject private function" {
    InModuleScope -ModuleName Unity-Powershell {

        $MockObject = @{
            id = 'default'
            type = 0
            address = @('smtp.example.com')
        }

        $MockObjectMissingProperty = @{
            id = 'default'
            type = 0
        }

        $MockObjectList1 = @($MockObject,$MockObjectMissingProperty,$MockObject)
        $MockObjectList2 = @($MockObject,$MockObject,$MockObject)

        Context -Name "Testing resulting objects" {
            It -Name "Should return an UnitySmtpServer object" {
                $TypeName = 'UnitySmtpServer'
                $Object1 = New-UnityObject -Data $MockObject -TypeName $TypeName 
                $Object1.GetType().Name | Should Be $TypeName
            }
            It -Name "Each object returned should be an UnitySmtpServer object" {
                $TypeName = 'UnitySmtpServer'
                $List = @()
                $List += New-UnityObject -Data $MockObjectList2 -TypeName $TypeName 
                $List | ForEach-Object {$_.GetType().Name | Should Be $TypeName}
            }
        }

        Context -Name "Testing TypeName parameter" {
            It -Name "Should Throw if providing a non existent type" {
                {New-UnityObject -Data $MockObject -TypeName 'Wrong!'} | Should Throw
            }
            It -Name "Should not Throw if providing a valid type" {
                {New-UnityObject -Data $MockObject -TypeName 'UnitySmtpServer'} | Should Not Throw
            }
        }
    }   
}
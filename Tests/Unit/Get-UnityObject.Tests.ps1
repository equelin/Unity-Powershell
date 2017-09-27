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

Describe -Name "Unit testing Get-UnityObject private function" {
    InModuleScope -ModuleName Unity-Powershell {

        $MockSession = New-Object -TypeName UnitySession

        Context -Name "Testing with a wrong object's type" {
             
            $TypeName = 'UnityUser'

            $MockObject = New-Object -TypeName $TypeName

            Mock Invoke-Expression {return $MockObject}

            It -Name "Function should throw an error" {
                {Get-UnityObject -Data $MockObject -TypeName 'Wrong!' -Session $MockSession} | Should Throw
            }
        }

        Context -Name "Testing with a String object's type" {

            $TypeName = 'UnityUser'

            $MockString = 'MockString'

            $MockObject = New-Object -TypeName $TypeName
            $MockObject.id = "user_Test01"
            $MockObject.Name = "Test01"

            Mock Invoke-Expression {return $MockObject}

            $Result,$ResultID,$ResultName = Get-UnityObject -Data $MockString -TypeName $TypeName -Session $MockSession

            It -Name "Invoke-Expression should be called only 1 time" {
                Assert-MockCalled -CommandName Invoke-Expression -Times 1
            }

            It -name "Resulting object type should be $TypeName" {
                $Result.GetType().Name | Should Be $TypeName
            }

            It -name "ObjectID value should be $($MockObject.id)" {
                $ResultID | Should Be $MockObject.id
            }

            It -name "ObjectName value should be $($MockObject.Name)" {
                $ResultName | Should Be $MockObject.Name
            }
        }

        Context -Name "Testing with a UnityUser object who has ID and Name properties" {

            $TypeName = 'UnityUser'

            $MockObject = New-Object -TypeName $TypeName
            $MockObject.id = "user_Test01"
            $MockObject.Name = "Test01"

            Mock Invoke-Expression {return $MockObject}

            $Result,$ResultID,$ResultName = Get-UnityObject -Data $MockObject -TypeName $TypeName -Session $MockSession

            It -Name "Invoke-Expression should not be called" {
                Assert-MockCalled -CommandName Invoke-Expression -Times 0
            }

            It -name "Resulting object type should be $TypeName" {
                $Result.GetType().Name | Should Be $TypeName
            }

            It -name "ObjectID value should be $($MockObject.id)" {
                $ResultID | Should Be $MockObject.id
            }

            It -name "ObjectName value should be $($MockObject.Name)" {
                $ResultName | Should Be $MockObject.Name
            }
        }

        Context -Name "Testing with a UnitySmtpServer object who has only ID property" {

            $TypeName = 'UnitySmtpServer'

            $MockObject = New-Object -TypeName $TypeName
            $MockObject.id = "default"

            Mock Invoke-Expression {return $MockObject}

            $Result,$ResultID,$ResultName = Get-UnityObject -Data $MockObject -TypeName $TypeName -Session $MockSession

            It -Name "Invoke-Expression should not be called" {
                Assert-MockCalled -CommandName Invoke-Expression -Times 0
            }

            It -name "Resulting object type should be $TypeName" {
                $Result.GetType().Name | Should Be $TypeName
            }

            It -name "ObjectID value should be $($MockObject.id)" {
                $ResultID | Should Be $MockObject.id
            }

            It -name "ObjectName value should be $($MockObject.id)" {
                $ResultName | Should Be $MockObject.id
            }
        }
    }
}
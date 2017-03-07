$here = Split-Path -Parent $MyInvocation.MyCommand.Path

#Get information from the module manifest
$manifestPath = "$here\..\..\Unity-Powershell\Unity-Powershell.psd1"
$manifest = Test-ModuleManifest -Path $manifestPath

#Test if a Unity-Powershell module is already loaded
$Module = Get-Module -Name 'Unity-Powershell' -ErrorAction SilentlyContinue

#Load the module if needed (not already loaded or not the good version)
If ($Module) {
    If ($Module.Version -ne $manifest.version) {
        Remove-Module $Module
        $Module = Import-Module "$here\..\..\Unity-Powershell" -Version $manifest.version -force
    }
} else {
    $Module = Import-Module "$here\..\..\Unity-Powershell" -Version $manifest.version -force
}

# Load the datas
. $here\Function.Data.ps1

<#
# Pester tests
Describe "No public function left behind" {

    $Module.ExportedFunctions.GetEnumerator() | ForEach-Object {
        $Name = $_.Value.Name

        It "Function $Name is tested in this test" {
            $data.values.name -contains $Name | Should Be $True
        }
    }
}
#>

Describe "Functions Parameters" {

    $Data.GetEnumerator() | ForEach-Object {

        $Name = $_.Value.Name
        $Params = $_.Value.Parameters

        Context "$Name" {
            $Command = Get-Command -Name $Name

            Foreach ($Param in $Params) {

                It "Function $($command.Name) contains Parameter $($Param['Name'])" {
                    $Command.Parameters.Keys -contains $Param['Name'] | Should Be $True
                }

                It "Function $($Param['Name']) type is $($Param['type'])" {
                    $Command.Parameters.($Param['Name']).ParameterType.Name -eq $Param['Type'] | Should Be $True
                }
            }
        }
    }
}


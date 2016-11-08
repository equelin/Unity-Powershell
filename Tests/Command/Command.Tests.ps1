$here = Split-Path -Parent $MyInvocation.MyCommand.Path

Import-Module "$here\..\..\Unity-Powershell" -force

Describe "Commands Parameters" {
    Context "Connect-Unity" {
        $Command = Get-Command -Name 'Connect-Unity'

        $Params = @(
            @{'Name' = 'Server'; 'type' = 'String[]'},
            @{'Name' = 'Session'; 'type' = 'UnitySession'}
        )

        Foreach ($Param in $Params) {

            It "Command $($command.Name) contains Parameter $($Param['Name'])" {
                $Command.Parameters.Keys -contains $Param['Name'] | Should Be $True
            }

            It "Parameter $($Param['Name']) type is $($Param['type'])" {
                $Command.Parameters.($Param['Name']).ParameterType.Name -eq $Param['Type'] | Should Be $True
            }
        }
    }
}

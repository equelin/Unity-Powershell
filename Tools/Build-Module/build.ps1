<#
.NOTES
https://github.com/equelin/unity-powershell
#>

[cmdletbinding()]
param(
    [string[]]$Task = 'default'
)

if (!(Get-Module -Name PlatyPS -ListAvailable)) { Install-Module -Name PlatyPS -Scope CurrentUser }
if (!(Get-Module -Name psake -ListAvailable)) { Install-Module -Name psake -Scope CurrentUser }
if (!(Get-Module -Name BuildHelpers -ListAvailable)) { Install-Module -Name BuildHelpers -Scope CurrentUser }

Invoke-psake -buildFile "$PSScriptRoot\psakeBuild.ps1" -taskList $Task -Verbose:$VerbosePreference
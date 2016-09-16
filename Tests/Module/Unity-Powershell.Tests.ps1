$here = Split-Path -Parent $MyInvocation.MyCommand.Path

$manifestPath = "$here\..\..\Unity-Powershell\Unity-Powershell.psd1"

Import-Module "$here\..\..\Unity-Powershell" -force

Describe -Tags 'VersionChecks' "Unity-Powershell manifest" {
    $script:manifest = $null
    It "has a valid manifest" {
        {
            $script:manifest = Test-ModuleManifest -Path $manifestPath -ErrorAction Stop -WarningAction SilentlyContinue
        } | Should Not Throw
    }

    It "has a valid name in the manifest" {
        $script:manifest.Name | Should Be 'Unity-Powershell'
    }

    It "has a valid guid in the manifest" {
        $script:manifest.Guid | Should Be '586e7e62-9753-4fd6-91b6-89d8d89d69a2'
    }

    It "has a valid version in the manifest" {
        $script:manifest.Version -as [Version] | Should Not BeNullOrEmpty
    }
}
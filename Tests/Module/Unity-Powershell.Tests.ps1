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

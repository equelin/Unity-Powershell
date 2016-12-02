# Grab nuget bits, install modules, set build variables, start build.
Add-AppVeyorLog -Message 'Get NuGEt package provider' -Category 'Information'
Get-PackageProvider -Name NuGet -ForceBootstrap -ErrorAction Stop| Out-Null

# Import module from PSGallery
Add-AppVeyorLog -Message 'Import modules from PSGallery' -Category 'Information' -Details 'Module list: PSDeploy, Pester, BuildHelpers, Format-Pester'
Resolve-Module PSDeploy, Pester, BuildHelpers, Format-Pester -ErrorAction Stop

# Set Build environment variables, get them from BuildHelpers module
Add-AppVeyorLog -Message 'Set build environment variables' -Category 'Information'
Set-BuildEnvironment -ErrorAction Stop

# Get module version
Add-AppVeyorLog -Message 'Get module version' -Category 'Information'
$ENV:BHModuleVersion = (Test-ModuleManifest -Path $ENV:BHPSModuleManifest).version

# Get PSGallery latest published module version
Add-AppVeyorLog -Message 'Get PSGallery latest module version' -Category 'Information'
$PSGalleryRelease = Find-Module -Name $ENV:BHProjectName -Repository PSGallery -ErrorAction SilentlyContinue

# Tests if the module has already been published on PSGallery, if not set the latest version to 0.0.0
If ($PSGalleryRelease) {
    $ENV:BHPSGalleryLatestModuleVersion = [version]($PSGalleryRelease.version)
} else {
    $ENV:BHPSGalleryLatestModuleVersion = [version]'0.0.0'
}

# Get GitHub latest published release
Add-AppVeyorLog -Message 'Get GitHub latest release' -Category 'Information'
$GitHubRelease = Get-GitHubRelease -username 'equelin' -repository $ENV:BHProjectName 

# Tests if there is an existing release on GitHub, if not set the latest release version to 0.0.0
If ($GitHubRelease) {
    $ENV:BHGitHubLatestReleaseVersion = [version]($GitHubRelease.tag_name | Select-Object -First 1)
} else {
    $ENV:BHGitHubLatestReleaseVersion = [version]'0.0.0'
}

# Show environment variables on the AppVeyor console - TODO: Show these informations on the AppVeyor's messages page
Get-Item ENV:BH*


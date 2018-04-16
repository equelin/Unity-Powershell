#
# Module manifest for module 'Unity-Powershell'
#
# Generated by: Erwan Quelin
#
# Generated on: 24/05/2016
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'Unity-Powershell.psm1'

# Version number of this module.
ModuleVersion = '0.16.1'

# ID used to uniquely identify this module
GUID = '586e7e62-9753-4fd6-91b6-89d8d89d69a2'

# Author of this module
Author = 'Erwan Quelin'

# Company or vendor of this module
#CompanyName = 'Unknown'

# Copyright statement for this module
Copyright = 'Licensed under the MIT License (c) 2016-2017 Erwan Quelin. https://github.com/equelin/Unity-Powershell/blob/master/LICENSE'

# Description of the functionality provided by this module
Description = 'Powershell module for working with EMC Unity array'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '5.0'

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
FormatsToProcess = @('.\Format\Unity-Powershell.UnityAlert.Format.ps1xml','.\Format\Unity-Powershell.UnityAlertConfig.Format.ps1xml','.\Format\Unity-Powershell.UnityBasicSystemInfo.Format.ps1xml','.\Format\Unity-Powershell.Unitybattery.Format.ps1xml','.\Format\Unity-Powershell.UnityCIFSServer.Format.ps1xml','.\Format\Unity-Powershell.UnityCIFSShare.Format.ps1xml','.\Format\Unity-Powershell.UnityDae.Format.ps1xml','.\Format\Unity-Powershell.UnitydataCollectionResult.Format.ps1xml','.\Format\Unity-Powershell.Unitydatastore.Format.ps1xml','.\Format\Unity-Powershell.UnityDisk.Format.ps1xml','.\Format\Unity-Powershell.UnityDiskGroup.Format.ps1xml','.\Format\Unity-Powershell.UnityDNSServer.Format.ps1xml','.\Format\Unity-Powershell.UnityDpe.Format.ps1xml','.\Format\Unity-Powershell.UnityEncryption.Format.ps1xml','.\Format\Unity-Powershell.UnityEthernetPort.Format.ps1xml','.\Format\Unity-Powershell.UnityFastCache.Format.ps1xml','.\Format\Unity-Powershell.UnityfastVP.Format.ps1xml','.\Format\Unity-Powershell.UnityfcPort.Format.ps1xml','.\Format\Unity-Powershell.UnityFeature.Format.ps1xml','.\Format\Unity-Powershell.UnityFileDNSServer.Format.ps1xml','.\Format\Unity-Powershell.UnityFileInterface.Format.ps1xml','.\Format\Unity-Powershell.UnityFilesystem.Format.ps1xml','.\Format\Unity-Powershell.UnityHost.Format.ps1xml','.\Format\Unity-Powershell.UnityHostContainer.Format.ps1xml','.\Format\Unity-Powershell.UnityHostInitiator.Format.ps1xml','.\Format\Unity-Powershell.UnityHostIPPort.Format.ps1xml','.\Format\Unity-Powershell.UnityinstalledSoftwareVersion.Format.ps1xml','.\Format\Unity-Powershell.UnityIpInterface.Format.ps1xml','.\Format\Unity-Powershell.UnityIpPort.Format.ps1xml','.\Format\Unity-Powershell.UnityIscsiPortal.Format.ps1xml','.\Format\Unity-Powershell.UnityJob.Format.ps1xml','.\Format\Unity-Powershell.UnityLicense.Format.ps1xml','.\Format\Unity-Powershell.UnitylinkAggregation.Format.ps1xml','.\Format\Unity-Powershell.UnityLUN.Format.ps1xml','.\Format\Unity-Powershell.UnityMetric.Format.ps1xml','.\Format\Unity-Powershell.UnityMetricQueryResult.Format.ps1xml','.\Format\Unity-Powershell.UnityMetricRealTimeQuery.Format.ps1xml','.\Format\Unity-Powershell.UnityMetricValue.Format.ps1xml','.\Format\Unity-Powershell.UnityMgmtInterface.Format.ps1xml','.\Format\Unity-Powershell.UnityMgmtInterfaceSettings.Format.ps1xml','.\Format\Unity-Powershell.UnityNasServer.Format.ps1xml','.\Format\Unity-Powershell.UnityNfsServer.Format.ps1xml','.\Format\Unity-Powershell.UnityNFSShare.Format.ps1xml','.\Format\Unity-Powershell.UnityNTPServer.Format.ps1xml','.\Format\Unity-Powershell.UnityPool.Format.ps1xml','.\Format\Unity-Powershell.UnityPoolUnit.Format.ps1xml','.\Format\Unity-Powershell.UnityserviceAction.Format.ps1xml','.\Format\Unity-Powershell.UnityserviceInfo.Format.ps1xml','.\Format\Unity-Powershell.UnitySession.Format.ps1xml','.\Format\Unity-Powershell.UnitySmtpServer.Format.ps1xml','.\Format\Unity-Powershell.UnitySnap.Format.ps1xml','.\Format\Unity-Powershell.UnitySnapSchedule.Format.ps1xml','.\Format\Unity-Powershell.UnitySnapScheduleRule.Format.ps1xml','.\Format\Unity-Powershell.UnitySsc.Format.ps1xml','.\Format\Unity-Powershell.UnitySsd.Format.ps1xml','.\Format\Unity-Powershell.UnityStorageProcessor.Format.ps1xml','.\Format\Unity-Powershell.UnitystorageResource.Format.ps1xml','.\Format\Unity-Powershell.UnitySystem.Format.ps1xml','.\Format\Unity-Powershell.UnityUser.Format.ps1xml','.\Format\Unity-Powershell.Unityvm.Format.ps1xml','.\Format\Unity-Powershell.UnityvmwareNasPEServer.Format.ps1xml','.\Format\Unity-Powershell.UnityvmwarePE.Format.ps1xml','.\Format\Unity-Powershell.Unityx509Certificate.Format.ps1xml')

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
# NestedModules = @()

# Functions to export from this module
FunctionsToExport = @('Connect-Unity','Disable-UnityFastCache','Disconnect-Unity','Enable-UnityFastCache','Get-UnityAlert','Get-UnityAlertConfig','Get-UnityBasicSystemInfo','Get-UnityBattery','Get-UnityCIFSServer','Get-UnityCIFSShare','Get-UnityDae','Get-UnityDataCollectionResult','Get-UnityDatastore','Get-UnityDisk','Get-UnityDiskGroup','Get-UnityDNSServer','Get-UnityDpe','Get-UnityEncryption','Get-UnityESXi','Get-UnityEthernetPort','Get-UnityFastCache','Get-UnityFastVP','Get-UnityFCPort','Get-UnityFeature','Get-UnityFileDNSServer','Get-UnityFileInterface','Get-UnityFilesystem','Get-UnityHost','Get-UnityHostInitiator','Get-UnityHostIPPort','Get-UnityInstalledSoftwareVersion','Get-UnityIpInterface','Get-UnityIPPort','Get-UnityIscsiPortal','Get-UnityItem','Get-UnityJob','Get-UnityLicense','Get-UnityLinkAggregation','Get-UnityLUN','Get-UnityMetric','Get-UnityMetricQueryResult','Get-UnityMetricRealTimeQuery','Get-UnityMetricValue','Get-UnityMgmtInterface','Get-UnityMgmtInterfaceSetting','Get-UnityNASServer','Get-UnityNFSServer','Get-UnityNFSShare','Get-UnityNTPServer','Get-UnityPool','Get-UnityPoolUnit','Get-UnityServiceAction','Get-UnityServiceInfo','Get-UnitySession','Get-UnitySMTPServer','Get-UnitySnap','Get-UnitySnapSchedule','Get-UnitySsc','Get-UnitySsd','Get-UnityStorageProcessor','Get-UnityStorageResource','Get-UnitySystem','Get-UnityUser','Get-UnityvCenter','Get-UnityVM','Get-UnityVMwareLUN','Get-UnityVMwareNasPEServer','Get-UnityVMwareNFS','Get-UnityVMwarePE','Get-UnityX509Certificate','Invoke-UnityRefreshLUNThinClone','Invoke-UnityRefreshVMwareLUNThinClone','New-UnityCIFSServer','New-UnityCIFSShare','New-UnityFileDNSServer','New-UnityFileInterface','New-UnityFilesystem','New-UnityHost','New-UnityHostIPPort','New-UnityiSCSIPortal','New-UnityLUN','New-UnityLUNThinClone','New-UnityMetricRealTimeQuery','New-UnityMgmtInterface','New-UnityNASServer','New-UnityNFSServer','New-UnityNFSShare','New-UnityPool','New-UnitySMTPServer','New-UnitySnap','New-UnitySnapSchedule','New-UnityUser','New-UnityvCenter','New-UnityVMwareLUN','New-UnityVMwareLUNThinClone','New-UnityVMwareNFS','Remove-UnityAlert','Remove-UnityCIFSServer','Remove-UnityCIFSShare','Remove-UnityFileDNSServer','Remove-UnityFileInterface','Remove-UnityFilesystem','Remove-UnityHost','Remove-UnityHostIPPort','Remove-UnityiSCSIPortal','Remove-UnityLUN','Remove-UnityMgmtInterface','Remove-UnityNASServer','Remove-UnityNFSServer','Remove-UnityNFSShare','Remove-UnityPool','Remove-UnitySMTPServer','Remove-UnitySnap','Remove-UnitySnapSchedule','Remove-UnityUser','Remove-UnityvCenter','Remove-UnityVMwareLUN','Remove-UnityVMwareNFS','Save-UnityDataCollectionResult','Set-UnityAlert','Set-UnityAlertConfig','Set-UnityCIFSShare','Set-UnityDNSServer','Set-UnityFileDNSServer','Set-UnityFileInterface','Set-UnityFilesystem','Set-UnityHost','Set-UnityHostIPPort','Set-UnityIscsiPortal','Set-UnityLUN','Set-UnityMgmtInterface','Set-UnityMgmtInterfaceSetting','Set-UnityNASServer','Set-UnityNFSServer','Set-UnityNFSShare','Set-UnityNTPServer','Set-UnityPool','Set-UnityServiceAction','Set-UnitySMTPServer','Set-UnitySnap','Set-UnitySnapSchedule','Set-UnitySystem','Set-UnityUser','Set-UnityvCenter','Set-UnityVMwareLUN','Set-UnityVMwareNFS','Test-UnityEmailAlert','Test-UnityUCAlert','Test-UnityUIAlert','Update-UnityvCenter')

# Cmdlets to export from this module
CmdletsToExport = '*'

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module
AliasesToExport = '*'

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
# FileList = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @('EMC','Unity','API','Rest')

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/equelin/Unity-Powershell/blob/master/LICENSE'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/equelin/Unity-Powershell'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        # ReleaseNotes = ''

    } # End of PSData hashtable

} # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

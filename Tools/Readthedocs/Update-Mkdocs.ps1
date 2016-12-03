#Requires -Modules PSYaml

<#
.SYNOPSIS
This is a really quick and dirty function for updating mkdocs.yml file
.NOTES
Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
.LINK
https://github.com/equelin/Unity-Powershell
.EXAMPLE
.\Convert-ClassToPS1xml.ps1 -TypeName 'UnityPool' -TableHeaderList id,name -OutputPath F:\

Build format file.
#>

[CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
Param (
    [Parameter(Mandatory = $true)]
    [String]$MkdocsFile,
    [Parameter(Mandatory = $false)]
    [String]$ReferenceFolder = '.'
)

$yml = ConvertFrom-Yaml -Path $MkdocsFile

$ReferenceItems = Get-ChildItem -Path $ReferenceFolder



foreach ($Item in $ReferenceItems) {

    Write-Verbose "$($Item.Name)"

    Write-Host "- $($Item.BaseName): References/$($Item.Name) "

}

<#
    .SYNOPSIS
    Output / Format Enums from API
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $false)]
    [String]$OutputFile = '.\Enum.ps1'
)

$types = Get-UnityItem -URI /api/types

$Enums = ($types.entries.content | Where-Object { $_.name -like '*Enum'})

"#START" | Out-File $OutputFile

Foreach ($Enum in $Enums) {

    "<#" | Out-File $OutputFile -Append
    "  Name: $($Enum.Name)" | Out-File $OutputFile -Append
    "  Description: $($Enum.Description)" | Out-File $OutputFile -Append
    "#>" | Out-File $OutputFile -Append

    "Enum $($Enum.Name) {" | Out-File $OutputFile -Append

    Foreach ($Attribut in ($Enum.attributes)) {
        "  $($attribut.name) = $($attribut.initialValue) #$($attribut.description)" | Out-File $OutputFile -Append
    }

    "}" | Out-File $OutputFile -Append
    "" | Out-File $OutputFile -Append
}
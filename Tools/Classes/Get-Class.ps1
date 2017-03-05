<#
    .SYNOPSIS
    Output / Format CLasses from API
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $false)]
    [String]$OutputFile = '.\Classes.ps1'
)

Function Format-Type {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $false)]
        [String]$Type
    )

    Process {
        Switch -Wildcard ($Type) {
            'Integer' {$output = 'Int'}
            'Boolean' {$output = 'Bool'}
            'String' {$output = 'String'}
            'List<*>' {
                $Type = ($Type.Substring(5)) -replace '>',''
                $output = (Format-Type -Type $Type)+'[]'
            }
            'Datetime' {$output = 'DateTime'}
            'health' {$output = 'UnityHealth'}
            'float' {$output = 'Float'}
            '*Enum' {$Output = $Type}
            Default {$Output = 'Object'}
        }

        $Output
    }    
}

$types = Get-UnityItem -URI /api/types

$Classes = ($types.entries.content | Where-Object { $_.name -notlike '*Enum'})

"#START" | Out-File $OutputFile

Foreach ($Class in $Classes) {

    "<#" | Out-File $OutputFile -Append
    "  Name: Unity$($Class.Name)" | Out-File $OutputFile -Append
    "  Description: $($Class.Description)" | Out-File $OutputFile -Append
    "#>" | Out-File $OutputFile -Append
    "Class Unity$($Class.Name) {" | Out-File $OutputFile -Append
    "" | Out-File $OutputFile -Append
    "  #Properties" | Out-File $OutputFile -Append
    "" | Out-File $OutputFile -Append

    Foreach ($Attribut in ($Class.attributes)) {

        $Type = Format-Type -Type $attribut.type

        "  [$Type]$"+"$($attribut.name) #$($attribut.description)" | Out-File $OutputFile -Append
    }

    "" | Out-File $OutputFile -Append
    "  #Methods" | Out-File $OutputFile -Append
    "" | Out-File $OutputFile -Append
    "}" | Out-File $OutputFile -Append
    "" | Out-File $OutputFile -Append
}
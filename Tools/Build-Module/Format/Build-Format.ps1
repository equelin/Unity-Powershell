[CmdletBinding()]
Param (
    $Classes
)

Foreach ($Classes in ($cfg.classes)) {
    Write-Verbose "Processing class $Class.TypeName"
    .\Convert-ClassToPS1xml.ps1 -TypeName $Class.TypeName -TableHeaderList $Class.TableHeaderList -OutputPath F:\Code\GitHub\Unity-Powershell\Unity-Powershell\Format\ 
}
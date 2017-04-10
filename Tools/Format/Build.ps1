[CmdletBinding()]
Param ()

$here = Split-Path -Parent $MyInvocation.MyCommand.Path

. $here\Data.ps1

Foreach ($Class in ($Data.Class)) {
    Write-Verbose "Processing class $Class.TypeName"
    .\Convert-ClassToPS1xml.ps1 -TypeName $Class.TypeName -TableHeaderList $Class.TableHeaderList -OutputPath F:\Code\GitHub\Unity-Powershell\Unity-Powershell\Format\ 
}
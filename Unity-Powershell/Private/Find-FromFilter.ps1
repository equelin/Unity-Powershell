function Find-FromFilter {
    [CmdletBinding()]
    Param (
    [parameter(Mandatory = $true)]
    $Data,
    [parameter(Mandatory = $true)]
    [String]$Parameter,
    [parameter(Mandatory = $true)]
    $Filter
    )

    Process {
        Write-Verbose "Executing function: $($MyInvocation.MyCommand)"

        Foreach ($F in $Filter) {
            Write-Verbose "Filtering result(s) on parameter $Parameter withe value $F"
            $Data | Where-Object {$_."$Parameter" -like $F}
        }
    }


}

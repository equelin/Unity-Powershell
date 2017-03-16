Function Find-FromFilter {
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
        Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

        Foreach ($F in $Filter) {
            Write-Debug -Message "[$($MyInvocation.MyCommand)] Filtering result(s) on parameter $Parameter with value $F"
            $Result = $Data | Where-Object {$_."$Parameter" -like $F}
            Write-Debug -Message "[$($MyInvocation.MyCommand)] Found $($Result.Count) item(s)"

            $Result
        }
    }
}

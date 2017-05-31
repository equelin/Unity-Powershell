function Get-UnityObject {
    [CmdletBinding()]
    Param (
        [parameter(Mandatory = $true)]
        [Object]$Data,
        [parameter(Mandatory = $true)]
        [String]$Typename,
        [parameter(Mandatory = $false)]
        [String]$Command,
        [Parameter(Mandatory = $true,HelpMessage = 'EMC Unity Session')]
        [UnitySession]$Session
    )

    Process {
        
        $ObjectTypeName = $Data.GetType().Name

        Write-Verbose -Message "Object Type is $ObjectTypeName"

        If (-NOT $PSBoundParameters.ContainsKey('command')) {
              $command = $Typename
        } 

        Switch ($ObjectTypeName) {
            "String" {$Object = (Invoke-Expression -Command "Get-$($Command) -ID `$Data -Session `$Session")}
            "$TypeName" {$Object = $Data}
            default { throw [System.IO.FileNotFoundException]::New() }
        }

        If ($Object.Name) {
            Write-Verbose -Message "Object ID: $($Object.id),Object Name: $($Object.name)"
            Return $Object,$Object.id,$Object.Name
        } else {
            Write-Verbose -Message "Object ID: $($Object.id)"
            Return $Object,$Object.id,$Object.id
        }
    }
}
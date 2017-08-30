function New-UnityObject {
    [CmdletBinding()]
    Param (
      [parameter(Mandatory = $true)]
      $Data,
      [parameter(Mandatory = $true)]
      $TypeName
    )
  
    Write-Debug -Message "[$($MyInvocation.MyCommand.Name)] Executing function"
	Write-Debug -Message "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
	Write-Debug -Message "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"
  
    #Building the result collection
    Foreach ($D in $Data) {

        # Create a new empty object of type $Typename
        $Object = New-Object -TypeName $TypeName

        # Loop through all the object properties and add to it the data
        $Object | Get-Member -MemberType Property | ForEach-Object {
            If ($D."$($_.name)" -notlike $null) {
                Write-Debug -Message "[$($MyInvocation.MyCommand)] Add key: $($_.name) with value: $($D.$($_.name))"
                $Object."$($_.name)" = $D."$($_.name)"
            } else {
                Write-Debug -Message "[$($MyInvocation.MyCommand)] No value to add to Key: $($_.name)"
            }
        }

        Return $Object
    }
  }
  
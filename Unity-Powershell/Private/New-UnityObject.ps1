function New-UnityObject {
    [CmdletBinding()]
    Param (
      [parameter(Mandatory = $true)]
      [Object[]]$Data,
      [parameter(Mandatory = $true)]
      [String]$TypeName
    )
  
    Write-Debug -Message "[$($MyInvocation.MyCommand.Name)] Executing function"
	Write-Debug -Message "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
	Write-Debug -Message "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"
  
    #Building the result collection
    Foreach ($D in $Data) {

        # Create a new empty object of type $Typename
        Try {
            $Object = New-Object -TypeName $TypeName
        }
        Catch {
            Throw "$TypeName is an invalid object"
        }
        
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
  
function ConvertTo-Hashtable {
  [CmdletBinding()]
  Param (
    [parameter(Mandatory = $true)]
    $Data
  )

  Write-Verbose "Executing function: $($MyInvocation.MyCommand)"

  #Building the result collection
  Foreach ($D in $Data) {
      $HashTable = @{}

      $D | 
        get-member -MemberType NoteProperty | 

        ForEach-Object {
          $HashTable.add($_.name,$D."$($_.name)")
        }

      # Output results
      $HashTable
  }
}

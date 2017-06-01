function ConvertTo-Hashtable {
  [CmdletBinding()]
  Param (
    [parameter(Mandatory = $true)]
    $Data
  )

  Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

  #Building the result collection
  Foreach ($D in $Data) {
      $HashTable = @{}

      $D | 
        get-member -MemberType NoteProperty | 

        ForEach-Object {
          Write-Debug -Message "[$($MyInvocation.MyCommand)] Add key: $($_.name) with value: $($D.$($_.name))"
          $HashTable.add($_.name,$D."$($_.name)")
        }

      # Output results
      $HashTable
  }
}

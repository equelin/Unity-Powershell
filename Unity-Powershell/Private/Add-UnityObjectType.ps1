#Deprecated, replaced by ConvertTo-Hashtable

function Add-UnityObjectType {
  [CmdletBinding()]
  Param (
    [parameter(Mandatory = $true)]
    $Data,
    [parameter(Mandatory = $true)]
    [string]$TypeName
  )

  Write-Verbose "Executing function: $($MyInvocation.MyCommand)"

  #Building the result collection (Add type)
  Foreach ($D in $Data) {
    $object = New-Object $TypeName
    $Data | get-member -type NoteProperty | foreach-object {
                                              If ($D."$($_.Name)") {
                                                $object."$($_.Name)" = $D."$($_.Name)"
                                              }
                                            }

    #Adding the request result object to the result's collection array
    Write-Output  $object
  }
}

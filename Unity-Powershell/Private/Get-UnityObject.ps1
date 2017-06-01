Function Get-UnityObject {

  <#
      .SYNOPSIS
      This private function allow to refer to an Unity object by ID instead of passing an actual object.
      .DESCRIPTION
      This private function allow to refer to a Unity object by name instead of passing an actual object.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Data
      Unity object or string refering to an object's id
      .PARAMETER Typename
      Type of the object
      .PARAMETER Session
      UnitySession Object.
      .EXAMPLE
      Get-UnityObject -Data $Data -Typename 'UnityUser' -Session $Sess

      Retrieve informations about query who's ID is 5.
  #>

    [CmdletBinding()]
    Param (
        [parameter(Mandatory = $true)]
        [Object]$Data,
        [parameter(Mandatory = $true)]
        [String]$Typename,
        [Parameter(Mandatory = $true,HelpMessage = 'EMC Unity Session')]
        [UnitySession]$Session
    )

    Begin {
        Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"
    }

    Process {
        
        $ObjectTypeName = $Data.GetType().Name

        Write-Verbose -Message "[$($MyInvocation.MyCommand)] Object Type is $ObjectTypeName"

        Switch ($ObjectTypeName) {
            "String" {$Object = (Invoke-Expression -Command "Get-$($Typename) -ID `$Data -Session `$Session")}
            "$TypeName" {$Object = $Data}
            default { throw [System.IO.FileNotFoundException]::New() }
        }

        If ($Object) {
            If ($Object.Name) {
                Write-Verbose -Message "[$($MyInvocation.MyCommand)] Object ID: $($Object.id),Object Name: $($Object.name)"
                Return $Object,$Object.id,$Object.Name
            } else {
                Write-Verbose -Message "[$($MyInvocation.MyCommand)] Object ID: $($Object.id)"
                Return $Object,$Object.id,$Object.id
            }
        } else {throw [System.IO.FileNotFoundException]::New()}
    }
}
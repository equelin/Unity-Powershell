Function Get-UnityVMwareLUN {

  <#
      .SYNOPSIS
      Queries the EMC Unity array to retrieve informations about VMware block LUN.
      .DESCRIPTION
      Querries the EMC Unity array to retrieve informations about VMware block LUN.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specifies an UnitySession Object.
      .PARAMETER Name
      Specifies the object name.
      .PARAMETER ID
      Specifies the object ID.
      .EXAMPLE
      Get-UnityVMwareLUN

      Retrieve information about all VMware block LUN
      .EXAMPLE
      Get-UnityVMwareLUN -Name 'DATASTORE01'

      Retrieves information about VMware block LUN named DATASTORE01
  #>

  [CmdletBinding(DefaultParameterSetName="ID")]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName="Name",ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'VMware LUN Name')]
    [String[]]$Name='*',
    [Parameter(Mandatory = $false,ParameterSetName="ID",ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'VMware LUN ID')]
    [String[]]$ID='*'
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $ResultCollection = @()
    $Typename = 'UnityVMwareLUN'

    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If ($Sess.TestConnection()) {

        $StorageResource = Get-UnitystorageResource -Session $Sess -Type 'vmwareiscsi'

        If ($StorageResource) {
          $ResultCollection += Get-UnityLUNResource -Session $Sess -ID $StorageResource.luns.id -Typename $Typename
        } 

      }
    }
  }

  Process {
    #Filter results
    If ($ResultCollection) {
      Switch ($PsCmdlet.ParameterSetName) {
        'Name' {
          Foreach ($N in $Name) {
            Write-Debug -Message "[$($MyInvocation.MyCommand)] Return result(s) with the filter: $($N)"
            Write-Output $ResultCollection | Where-Object {$_.Name -like $N}
            Write-Debug -Message "[$($MyInvocation.MyCommand)] Found $($ResultCollection.Count) item(s)"
          }
        }
        'ID' {
          Foreach ($I in $ID) {
            Write-Debug -Message "[$($MyInvocation.MyCommand)] Return result(s) with the filter: $($I)"
            Write-Output $ResultCollection | Where-Object {$_.Id -like $I}
            Write-Debug -Message "[$($MyInvocation.MyCommand)] Found $($ResultCollection.Count) item(s)"            
          }
        }
      } #End Switch
    } # End If ($ResultCollection)
  } # End Process
} # End Function

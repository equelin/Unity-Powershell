Function Get-UnityLUN {

  <#
      .SYNOPSIS
      Queries the EMC Unity array to retrieve informations about block LUN.
      .DESCRIPTION
      Querries the EMC Unity array to retrieve informations about block LUN.
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
      Get-UnityLUN

      Retrieve information about all block LUN
      .EXAMPLE
      Get-UnityLUN -Name 'LUN01'

      Retrieves information about block LUN named LUN01
  #>

  [CmdletBinding(DefaultParameterSetName="Name")]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName="Name",ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'LUN Name')]
    [String[]]$Name='*',
    [Parameter(Mandatory = $false,ParameterSetName="ID",ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'LUN ID')]
    [String[]]$ID='*'
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $ResultCollection = @()

    Foreach ($sess in $session) {

      Write-Debug -Message "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If ($Sess.TestConnection()) {

        $StorageResource = Get-UnityStorageResource -Session $Sess -Type 'lun' -ErrorAction SilentlyContinue

        If ($StorageResource) {
          $ResultCollection += Get-UnityLUNResource -Session $Sess -ID $StorageResource.luns.id -ErrorAction SilentlyContinue
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
            $Result = $ResultCollection | Where-Object {$_.Name -like $N}
            Write-Debug -Message "[$($MyInvocation.MyCommand)] Found $($ResultCollection.Count) item(s)"
          }
        }
        'ID' {
          Foreach ($I in $ID) {
            Write-Debug -Message "[$($MyInvocation.MyCommand)] Return result(s) with the filter: $($I)"
            $Result = $ResultCollection | Where-Object {$_.Id -like $I}
            Write-Debug -Message "[$($MyInvocation.MyCommand)] Found $($ResultCollection.Count) item(s)"            
          }
        }
      } #End Switch
      
      If ($Result) {
        $Result
      } else {
        Write-Error -Message "Object not found with the specified filter(s)" -Category "ObjectNotFound"
      } # End If ($Result)
    } else {
      Write-Error -Message "Object(s) not found" -Category "ObjectNotFound"
    } # End If ($ResultCollection)
  } # End Process
} # End Function

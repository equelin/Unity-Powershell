Function Get-UnityVMwareLUN {

  <#
      .SYNOPSIS
      Queries the EMC Unity array to retrieve informations about VMware block LUN.
      .DESCRIPTION
      Queries the EMC Unity array to retrieve informations about VMware block LUN.
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
    Write-Debug -Message "[$($MyInvocation.MyCommand.Name)] Executing function"
    Write-Debug -Message "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
    Write-Debug -Message "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

    #Initialazing variables
    $ResultCollection = @()
    $StorageResourceURI = '/api/types/storageResource/instances?fields=id,luns&filter=type eq 4'

    #Loop through each sessions
    Foreach ($Sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Sess.Server) with SessionId: $($Sess.SessionId)"

      #Test if session is alive
      If ($Sess.TestConnection()) {

        Write-Debug -Message "[$($MyInvocation.MyCommand)] Retrieve vmwareiscsi storage resources"
        $StorageResource = (($Sess.SendGetRequest($StorageResourceURI)).content | ConvertFrom-Json ).entries.content

        If ($StorageResource) {
          #Retrieve LUN associated to storage resources
          Write-Debug -Message "[$($MyInvocation.MyCommand)] Retrieve LUN associated to storage resources"
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

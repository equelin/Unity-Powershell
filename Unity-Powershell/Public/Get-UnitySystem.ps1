Function Get-UnitySystem {

  <#
      .SYNOPSIS
      Information about general settings for the storage system.
      .DESCRIPTION
      Information about general settings for the storage system.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under Apache licence
      .LINK
      https://github.com/equelin/Unity-Powershell
      .EXAMPLE
      Get-UnitySystem

      Retrieve informations about all the arrays with an active session.
      .EXAMPLE
      Get-UnitySystem -Name 'UnityVSA'


      Retrieves informations about an array named 'UnityVSA'
  #>

  [CmdletBinding(DefaultParameterSetName="ByName")]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName="ByName",ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'LUN Name')]
    [String[]]$Name='*',
    [Parameter(Mandatory = $false,ParameterSetName="ByID",ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'LUN ID')]
    [String[]]$ID='*'
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"

    #Initialazing arrays
    $ResultCollection = @()

    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If (Test-UnityConnection -Session $Sess) {

        #Building the URI
        $URI = 'https://'+$sess.Server+'/api/types/system/instances?compact=true&fields=id,health,name,model,serialNumber,internalModel,platform,macAddress'
        Write-Verbose "URI: $URI"

        #Sending the request
        $request = Send-UnityRequest -uri $URI -Session $Sess -Method 'GET'

        #Formating the result. Converting it from JSON to a Powershell object
        $results = ($request.content | ConvertFrom-Json).entries.content

        #Building the result collection (Add type)
        $ResultCollection += Add-UnityObjectType -Data $results -TypeName 'UnitySystem'

      } else {
        Write-Host "You are no longer connected to EMC Unity array: $($Sess.Server)"
      }
    }
  }

  Process {
    #Filter results
    If ($ResultCollection) {
      Switch ($PsCmdlet.ParameterSetName) {
        'ByName' {
          Foreach ($N in $Name) {
            Write-Verbose "Return result(s) with the filter: $($N)"
            $ResultCollectionFiltered += $ResultCollection | Where-Object {$_.Name -like $N}
          }
        }
        'ByID' {
          Foreach ($I in $ID) {
            Write-Verbose "Return result(s) with the filter: $($I)"
            $ResultCollectionFiltered += $ResultCollection | Where-Object {$_.Id -like $I}
          }
        }
      }
    }
  }

  End {
    return $ResultCollectionFiltered
  }

}

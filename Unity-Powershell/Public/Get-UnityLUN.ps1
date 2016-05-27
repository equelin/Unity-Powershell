Function Get-UnityLUN {

  <#
      .SYNOPSIS
      Queries the EMC Unity array to retrieve informations about LUN.
      .DESCRIPTION
      Querries the EMC Unity array to retrieve informations about LUN.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under Apache licence
      .LINK
      https://github.com/equelin/Unity-Powershell
      .EXAMPLE
      Get-UnityLUN

      Retrieve information about LUN
      .EXAMPLE
      Get-UnityLUN -Name 'LUN01'

      Retrieves information about LUN named LUN01
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
        $URI = 'https://'+$sess.Server+'/api/types/lun/instances?compact=true&fields=id,health,name,description,type,sizeTotal,sizeUsed,sizeAllocated,perTierSizeUsed,isThinEnabled,storageResource,pool,wwn,tieringPolicy,defaultNode,isReplicationDestination,currentNode,snapSchedule,isSnapSchedulePaused,ioLimitPolicy,metadataSize,metadataSizeAllocated,snapWwn,snapsSize,snapsSizeAllocated,hostAccess,snapCount'
        Write-Verbose "URI: $URI"

        #Sending the request
        $request = Send-UnityRequest -uri $URI -Session $Sess -Method 'GET'

        #Formating the result. Converting it from JSON to a Powershell object
        $results = ($request.content | ConvertFrom-Json).entries.content

        #Building the result collection (Add type)
        $ResultCollection += Add-UnityObjectType -Data $results -TypeName 'UnityLUN'

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
            Write-Output $ResultCollection | Where-Object {$_.Name -like $N}
          }
        }
        'ByID' {
          Foreach ($I in $ID) {
            Write-Verbose "Return result(s) with the filter: $($I)"
            Write-Output $ResultCollection | Where-Object {$_.Id -like $I}
          }
        }
      }
    }
  }

  End {}
}

Function Get-UnitystorageResource {

  <#
      .SYNOPSIS
      Queries the EMC Unity array to retrieve informations about UnitystorageResource.
      .DESCRIPTION
      Querries the EMC Unity array to retrieve informations about UnitystorageResource.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under Apache licence
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specifies an UnitySession Object.
      .PARAMETER Name
      Specifies the object name.
      .PARAMETER ID
      Specifies the object ID.
      .PARAMETER Type
      Specifies the storage ressource type. Might be:
      - lun
      - vmwareiscsi
      - vmwarefs
      .EXAMPLE
      Get-UnitystorageResource

      Retrieve informations about all the storage ressources
      .EXAMPLE
      Get-UnitystorageResource -Name 'DATASTORE01'

      Retrieves informations about storage ressource named DATASTORE01
  #>

  [CmdletBinding(DefaultParameterSetName="ByName")]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName="ByName",ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'LUN Name')]
    [String[]]$Name='*',
    [Parameter(Mandatory = $false,ParameterSetName="ByID",ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'LUN ID')]
    [String[]]$ID='*',
    [Parameter(Mandatory = $false,HelpMessage = 'Storage ressource type')]
    [ValidateSet('lun','vmwareiscsi','vmwarefs')]
    [String]$Type
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"

    #Initialazing variables
    $ResultCollection = @()
    $URI = '/api/types/storageResource/instances' #URI for the ressource (example: /api/types/lun/instances)
    $TypeName = 'UnitystorageResource'

    Switch ($Type) {
      'lun' {$Filter = 'type eq 8'}
      'vmwareiscsi' {$Filter = 'type eq 4'}
      'vmwarefs' {$Filter = 'type eq 3'}
    }

    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If ($Sess.TestConnection()) {

        #Building the URL from Object Type.
        $URL = Get-URLFromObjectType -Server $sess.Server -URI $URI -TypeName $TypeName -Filter $Filter

        Write-Verbose "URL: $URL"

        #Sending the request
        $request = Send-UnityRequest -uri $URL -Session $Sess -Method 'GET'

        #Formating the result. Converting it from JSON to a Powershell object
        $results = ($request.content | ConvertFrom-Json).entries.content

        #Building the result collection (Add ressource type)
        If ($results) {
            $ResultCollection += Add-UnityObjectType -Data $results -TypeName $TypeName
        }

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

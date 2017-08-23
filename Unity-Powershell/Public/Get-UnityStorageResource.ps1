Function Get-UnitystorageResource {

  <#
      .SYNOPSIS
      Queries the EMC Unity array to retrieve informations about UnitystorageResource.
      .DESCRIPTION
      Querries the EMC Unity array to retrieve informations about UnitystorageResource.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence
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

  [CmdletBinding(DefaultParameterSetName="Name")]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName="Name",ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Storage Resource Name')]
    [String[]]$Name,
    [Parameter(Mandatory = $false,ParameterSetName="ID",ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Storage Resource ID')]
    [String[]]$ID,
    [Parameter(Mandatory = $false,HelpMessage = 'Storage ressource type')]
    [ValidateSet('lun','vmwareiscsi','vmwarefs')]
    [String]$Type
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand.Name)] Executing function"
    Write-Debug -Message "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
    Write-Debug -Message "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

    #Initialazing variables
    $URI = '/api/types/storageResource/instances' #URI for the ressource (example: /api/types/lun/instances)
    $TypeName = 'UnitystorageResource'

    Switch ($Type) {
      'lun' {$Filter = 'type eq 8'}
      'vmwareiscsi' {$Filter = 'type eq 4'}
      'vmwarefs' {$Filter = 'type eq 3'}
    }
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName] -Filter $Filter

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function

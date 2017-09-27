Function Get-UnitycapabilityProfile {

  <#
      .SYNOPSIS
      An object representing VASA 2.0 SPBM capability profile. Capability profiles can be queried, created, modified and deleted via the REST API. Capability profiles can then be queried via VASA 2.0 API by vSphere environment and leveraged for policy based provisioning of virtual volumes.  
      .DESCRIPTION
      An object representing VASA 2.0 SPBM capability profile. Capability profiles can be queried, created, modified and deleted via the REST API. Capability profiles can then be queried via VASA 2.0 API by vSphere environment and leveraged for policy based provisioning of virtual volumes.  
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
      Get-UnitycapabilityProfile

      Retrieve information about all UnitycapabilityProfile
      .EXAMPLE
      Get-UnitycapabilityProfile -ID 'id01'

      Retrieves information about a specific UnitycapabilityProfile
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='Name',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnitycapabilityProfile Name')]
    [String[]]$Name,
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnitycapabilityProfile ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/capabilityProfile/instances' #URI
    $TypeName = 'UnitycapabilityProfile'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


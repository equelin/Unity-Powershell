Function Get-UnityhostInitiator {

  <#
      .SYNOPSIS
      Information about host initiators in the storage system. <br/> <br/> After you create a host configuration for controlling host access to storage on the system, you need to create a host initiator for each host configuration that accesses iSCSI or Fibre Channel (FC) storage. The initiator connects the host to the target iSCSI or FC node on the system. <br/> <br/> Initiator-based registration allows you to register the initiator to a host without having to manage individual paths. By default, when an initiator is registered to a host, all of its paths, including those specified after the registration takes place, are automatically granted access to any storage provisioned for the host. <br/>  
      .DESCRIPTION
      Information about host initiators in the storage system. <br/> <br/> After you create a host configuration for controlling host access to storage on the system, you need to create a host initiator for each host configuration that accesses iSCSI or Fibre Channel (FC) storage. The initiator connects the host to the target iSCSI or FC node on the system. <br/> <br/> Initiator-based registration allows you to register the initiator to a host without having to manage individual paths. By default, when an initiator is registered to a host, all of its paths, including those specified after the registration takes place, are automatically granted access to any storage provisioned for the host. <br/>  
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
      Get-UnityhostInitiator

      Retrieve information about all UnityhostInitiator
      .EXAMPLE
      Get-UnityhostInitiator -ID 'id01'

      Retrieves information about a specific UnityhostInitiator
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='Name',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnityhostInitiator Name')]
    [String[]]$Name,
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnityhostInitiator ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/hostInitiator/instances' #URI
    $TypeName = 'UnityhostInitiator'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


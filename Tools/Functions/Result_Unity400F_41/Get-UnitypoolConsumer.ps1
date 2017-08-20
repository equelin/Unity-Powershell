Function Get-UnitypoolConsumer {

  <#
      .SYNOPSIS
      poolConsumer class is representation of single object that consumes storage inside pools. There are two types of pool consumers: storage resources and NAS servers. NAS servers and storage resource except Consistency groups are always wholly allocated in one and only one storage pool. Consistency group can be allocated in more than one storage pool in case if the LUNs belonging to the group allocated in the different pools. The NAS servers consume space in the pool of constant size which is not changed once NAS server created.  
      .DESCRIPTION
      poolConsumer class is representation of single object that consumes storage inside pools. There are two types of pool consumers: storage resources and NAS servers. NAS servers and storage resource except Consistency groups are always wholly allocated in one and only one storage pool. Consistency group can be allocated in more than one storage pool in case if the LUNs belonging to the group allocated in the different pools. The NAS servers consume space in the pool of constant size which is not changed once NAS server created.  
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specifies an UnitySession Object.
      .PARAMETER ID
      Specifies the object ID.
      .EXAMPLE
      Get-UnitypoolConsumer

      Retrieve information about all UnitypoolConsumer
      .EXAMPLE
      Get-UnitypoolConsumer -ID 'id01'

      Retrieves information about a specific UnitypoolConsumer
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnitypoolConsumer ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/poolConsumer/instances' #URI
    $TypeName = 'UnitypoolConsumer'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


Function Get-UnityfileEventsPublisher {

  <#
      .SYNOPSIS
      File Event Service is a mechanism whereby applications can register to receive event notification and context from sources such as VNX(e). File Event Service is a part of VNX Event Enabler Framework (VEE). VEE provides the working environment for the CAVA and CEPA (Common Event Publishing Agent) facilities. The event publishing agent delivers to the application both event notification and associated context in one message. Context may consist of file metadata or directory metadata needed to decide business policy. The CEPA sub-facilities include: - Auditing.A mechanism for delivering post-events to registered consumer applications in a synchronous manner. Events are delivered individually in real-time. - CQM.A mechanism for delivering pre-events to registered consumer applications in a synchronous manner. Events are delivered individually in real-time, allowing the consumer application to exercise business policy on the event. - VCAPS.A mechanism for delivering post-events in asynchronous mode. The delivery cadence is based on a time period or a number of events. - MessageExchange.A mechanism for delivering post-events in asynchronous mode, when needed, without consumer use of the CEPA API. Events are published from CEPA to the RabbitMQ CEE_Events exchange. A consumer application creates a queue for itself in the exchange from which it can retrieve events. <br/> <br/>  
      .DESCRIPTION
      File Event Service is a mechanism whereby applications can register to receive event notification and context from sources such as VNX(e). File Event Service is a part of VNX Event Enabler Framework (VEE). VEE provides the working environment for the CAVA and CEPA (Common Event Publishing Agent) facilities. The event publishing agent delivers to the application both event notification and associated context in one message. Context may consist of file metadata or directory metadata needed to decide business policy. The CEPA sub-facilities include: - Auditing.A mechanism for delivering post-events to registered consumer applications in a synchronous manner. Events are delivered individually in real-time. - CQM.A mechanism for delivering pre-events to registered consumer applications in a synchronous manner. Events are delivered individually in real-time, allowing the consumer application to exercise business policy on the event. - VCAPS.A mechanism for delivering post-events in asynchronous mode. The delivery cadence is based on a time period or a number of events. - MessageExchange.A mechanism for delivering post-events in asynchronous mode, when needed, without consumer use of the CEPA API. Events are published from CEPA to the RabbitMQ CEE_Events exchange. A consumer application creates a queue for itself in the exchange from which it can retrieve events. <br/> <br/>  
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
      Get-UnityfileEventsPublisher

      Retrieve information about all UnityfileEventsPublisher
      .EXAMPLE
      Get-UnityfileEventsPublisher -ID 'id01'

      Retrieves information about a specific UnityfileEventsPublisher
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='Name',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnityfileEventsPublisher Name')]
    [String[]]$Name,
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnityfileEventsPublisher ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/fileEventsPublisher/instances' #URI
    $TypeName = 'UnityfileEventsPublisher'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


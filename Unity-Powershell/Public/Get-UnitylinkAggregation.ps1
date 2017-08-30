Function Get-UnityLinkAggregation {

  <#
      .SYNOPSIS
      (Applies if link aggregation is supported.) Ethernet port link aggregation settings. <p/> Link aggregation lets you link Ethernet ports (for example, port 0 and port 1) on a Storage Processor (SP) to a single logical port, and therefore lets you use up to four Ethernet ports on the SP. If your system has two SPs, and you link two physical ports, the same ports on both SPs are linked for redundancy. For example, if you link port 0 to port 1, the system creates one link aggregation for these ports on SPA and another link aggregation on SPB. <p/> <b>Note: </b>You can aggregate only Ethernet ports belonging to the same I/O module or on-board Ethernet ports. Aggregation of ports from different I/O modules is not allowed. <p/> <b>Note: </b>You can aggregate only Ethernet ports with the same MTU size. <p/> <b>Note: </b>You can not add an Ethernet port to aggregation if there are iSCSI portals on it. <p/> Link aggregation provides the following advantages: <ul> <li>Increases overall throughput, since two physical ports are linked into one logical port.</li> <li>Provides basic load balancing across linked ports, since the network traffic is distributed across multiple physical ports.</li> <li>Provides redundant ports so that if one port in a linked pair fails, the system does not lose connectivity.</li> </ul> <b>Note: </b>With link aggregation, both linked ports must be connected to the same switch, and the switch must be configured to use the link aggregation that uses the Link Aggregation Control Protocol (LACP). The documentation that came with your switch should provide more information about using LACP. <p/> The Unisphere online Help provides more details on cabling the SPs to the Disk-Array Enclosures (DAEs).  
      .DESCRIPTION
      (Applies if link aggregation is supported.) Ethernet port link aggregation settings. <p/> Link aggregation lets you link Ethernet ports (for example, port 0 and port 1) on a Storage Processor (SP) to a single logical port, and therefore lets you use up to four Ethernet ports on the SP. If your system has two SPs, and you link two physical ports, the same ports on both SPs are linked for redundancy. For example, if you link port 0 to port 1, the system creates one link aggregation for these ports on SPA and another link aggregation on SPB. <p/> <b>Note: </b>You can aggregate only Ethernet ports belonging to the same I/O module or on-board Ethernet ports. Aggregation of ports from different I/O modules is not allowed. <p/> <b>Note: </b>You can aggregate only Ethernet ports with the same MTU size. <p/> <b>Note: </b>You can not add an Ethernet port to aggregation if there are iSCSI portals on it. <p/> Link aggregation provides the following advantages: <ul> <li>Increases overall throughput, since two physical ports are linked into one logical port.</li> <li>Provides basic load balancing across linked ports, since the network traffic is distributed across multiple physical ports.</li> <li>Provides redundant ports so that if one port in a linked pair fails, the system does not lose connectivity.</li> </ul> <b>Note: </b>With link aggregation, both linked ports must be connected to the same switch, and the switch must be configured to use the link aggregation that uses the Link Aggregation Control Protocol (LACP). The documentation that came with your switch should provide more information about using LACP. <p/> The Unisphere online Help provides more details on cabling the SPs to the Disk-Array Enclosures (DAEs).  
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
      Get-UnityLinkAggregation

      Retrieve information about all UnitylinkAggregation
      .EXAMPLE
      Get-UnityLinkAggregation -ID 'id01'

      Retrieves information about a specific UnitylinkAggregation
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='Name',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnitylinkAggregation Name')]
    [String[]]$Name,
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnitylinkAggregation ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/linkAggregation/instances' #URI
    $TypeName = 'UnitylinkAggregation'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


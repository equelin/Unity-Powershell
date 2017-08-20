Function Get-UnityreplicationSession {

  <#
      .SYNOPSIS
      Information about replication sessions. <br/> <br/> Replication is a process in which storage data is duplicated either locally or to a remote network device. Replication produces a read-only, point-in-time copy of source data and periodically updates the copy, keeping it consistent with the source data. Replication provides an enhanced level of redundancy in case the main storage backup system fails. As a result, the: <ul> <li>Downtime associated cost of a system failure is minimized. <li>Recovery process from a natural or human-caused disaster is facilitated. </ul> A replication session establishes an end-to-end path for a replication operation between a source and a destination. The replication source and destination may be local or remote. The session establishes the path that the data follows as it moves from source to destination.  
      .DESCRIPTION
      Information about replication sessions. <br/> <br/> Replication is a process in which storage data is duplicated either locally or to a remote network device. Replication produces a read-only, point-in-time copy of source data and periodically updates the copy, keeping it consistent with the source data. Replication provides an enhanced level of redundancy in case the main storage backup system fails. As a result, the: <ul> <li>Downtime associated cost of a system failure is minimized. <li>Recovery process from a natural or human-caused disaster is facilitated. </ul> A replication session establishes an end-to-end path for a replication operation between a source and a destination. The replication source and destination may be local or remote. The session establishes the path that the data follows as it moves from source to destination.  
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
      Get-UnityreplicationSession

      Retrieve information about all UnityreplicationSession
      .EXAMPLE
      Get-UnityreplicationSession -ID 'id01'

      Retrieves information about a specific UnityreplicationSession
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='Name',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnityreplicationSession Name')]
    [String[]]$Name,
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnityreplicationSession ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/replicationSession/instances' #URI
    $TypeName = 'UnityreplicationSession'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


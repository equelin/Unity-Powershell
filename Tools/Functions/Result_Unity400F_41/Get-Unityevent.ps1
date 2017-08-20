Function Get-Unityevent {

  <#
      .SYNOPSIS
      Information about the events reported by the storage system. <br/> <br/> The system monitors and reports on a variety of system events. It collects the events and writes them to the user log, which contains a record for each event. <br/> <br/> The health and alert providers promote some events to be alerts, which are usually events that require attention from the system administrator. For information about alerts, see the Help topic for the alert resource type. <br/> <br/> <b>In the username attribute, is the value N/A or blank if a user did not cause the event or the account is unavailable?</b>  
      .DESCRIPTION
      Information about the events reported by the storage system. <br/> <br/> The system monitors and reports on a variety of system events. It collects the events and writes them to the user log, which contains a record for each event. <br/> <br/> The health and alert providers promote some events to be alerts, which are usually events that require attention from the system administrator. For information about alerts, see the Help topic for the alert resource type. <br/> <br/> <b>In the username attribute, is the value N/A or blank if a user did not cause the event or the account is unavailable?</b>  
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
      Get-Unityevent

      Retrieve information about all Unityevent
      .EXAMPLE
      Get-Unityevent -ID 'id01'

      Retrieves information about a specific Unityevent
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='Name',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Unityevent Name')]
    [String[]]$Name,
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Unityevent ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/event/instances' #URI
    $TypeName = 'Unityevent'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


Function Get-UnityfileEventsPool {

  <#
      .SYNOPSIS
      File Event Service pool is a pool of remote File Event Service servers (machines that run VEE and are capable to handle event notificatons from the NAS Server). NAS Server can have one or several (up to three) File Event Service pools. The File Event Service pool servers are responsible for: - maintaining a topology and state mapping of all consumer applications - delivering event type and associated event metadata through the publishing agent API <br/> <br/>  
      .DESCRIPTION
      File Event Service pool is a pool of remote File Event Service servers (machines that run VEE and are capable to handle event notificatons from the NAS Server). NAS Server can have one or several (up to three) File Event Service pools. The File Event Service pool servers are responsible for: - maintaining a topology and state mapping of all consumer applications - delivering event type and associated event metadata through the publishing agent API <br/> <br/>  
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
      Get-UnityfileEventsPool

      Retrieve information about all UnityfileEventsPool
      .EXAMPLE
      Get-UnityfileEventsPool -ID 'id01'

      Retrieves information about a specific UnityfileEventsPool
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='Name',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnityfileEventsPool Name')]
    [String[]]$Name,
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnityfileEventsPool ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/fileEventsPool/instances' #URI
    $TypeName = 'UnityfileEventsPool'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


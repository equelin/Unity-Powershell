Function Get-UnityiscsiNode {

  <#
      .SYNOPSIS
      Information about the iSCSI nodes in the storage system. An iSCSI node represents a single iSCSI initiator or target. <br/> iSCSI nodes are created automatically on every non-aggregated Ethernet port except of ports used for management access.  
      .DESCRIPTION
      Information about the iSCSI nodes in the storage system. An iSCSI node represents a single iSCSI initiator or target. <br/> iSCSI nodes are created automatically on every non-aggregated Ethernet port except of ports used for management access.  
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
      Get-UnityiscsiNode

      Retrieve information about all UnityiscsiNode
      .EXAMPLE
      Get-UnityiscsiNode -ID 'id01'

      Retrieves information about a specific UnityiscsiNode
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='Name',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnityiscsiNode Name')]
    [String[]]$Name,
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnityiscsiNode ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/iscsiNode/instances' #URI
    $TypeName = 'UnityiscsiNode'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


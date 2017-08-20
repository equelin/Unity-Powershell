Function Get-UnityfileNDMPServer {

  <#
      .SYNOPSIS
      The NDMP server for the NAS Server. You can configure one NDMP server per NAS server. <br/> The Network Data Management Protocol (NDMP) provides a standard for backing up file servers on a network. NDMP allows centralized applications to back up file servers that run on various platforms and platform versions. NDMP reduces network congestion by isolating control path traffic from data path traffic, which permits centrally managed and monitored local backup operations. Storage systems support NDMP v2-v4 over the network. Direct-attach NDMP is not supported. This means that the tape drives need to be connected to a media server, and the NAS server communicates with the media server over the network. NDMP has an advantage when using multiprotocol file systems because it backs up the Windows ACLs as well as the UNIX security information.  
      .DESCRIPTION
      The NDMP server for the NAS Server. You can configure one NDMP server per NAS server. <br/> The Network Data Management Protocol (NDMP) provides a standard for backing up file servers on a network. NDMP allows centralized applications to back up file servers that run on various platforms and platform versions. NDMP reduces network congestion by isolating control path traffic from data path traffic, which permits centrally managed and monitored local backup operations. Storage systems support NDMP v2-v4 over the network. Direct-attach NDMP is not supported. This means that the tape drives need to be connected to a media server, and the NAS server communicates with the media server over the network. NDMP has an advantage when using multiprotocol file systems because it backs up the Windows ACLs as well as the UNIX security information.  
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
      Get-UnityfileNDMPServer

      Retrieve information about all UnityfileNDMPServer
      .EXAMPLE
      Get-UnityfileNDMPServer -ID 'id01'

      Retrieves information about a specific UnityfileNDMPServer
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='Name',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnityfileNDMPServer Name')]
    [String[]]$Name,
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnityfileNDMPServer ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/fileNDMPServer/instances' #URI
    $TypeName = 'UnityfileNDMPServer'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


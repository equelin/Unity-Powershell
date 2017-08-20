Function Get-UnitycifsShare {

  <#
      .SYNOPSIS
      Information about Common Internet File System (CIFS) shares in the storage system. <br/> <br/> CIFS shares use the CIFS protocol to provide an access point for configured Windows hosts to access file system storage. The system uses Active Directory to authenticate user and user group access to the share. <br/> <br/> <b>Note: </b>To manage CIFS shares for snaps, use the operations for this resource type. To manage CIFS shares for file systems, use the applicable operations for the storageResource resource type, as described in the help topic for that resource type.  
      .DESCRIPTION
      Information about Common Internet File System (CIFS) shares in the storage system. <br/> <br/> CIFS shares use the CIFS protocol to provide an access point for configured Windows hosts to access file system storage. The system uses Active Directory to authenticate user and user group access to the share. <br/> <br/> <b>Note: </b>To manage CIFS shares for snaps, use the operations for this resource type. To manage CIFS shares for file systems, use the applicable operations for the storageResource resource type, as described in the help topic for that resource type.  
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
      Get-UnitycifsShare

      Retrieve information about all UnitycifsShare
      .EXAMPLE
      Get-UnitycifsShare -ID 'id01'

      Retrieves information about a specific UnitycifsShare
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='Name',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnitycifsShare Name')]
    [String[]]$Name,
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnitycifsShare ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/cifsShare/instances' #URI
    $TypeName = 'UnitycifsShare'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


Function Get-UnitycifsServer {

  <#
      .SYNOPSIS
      Information about SMB server of a NAS server. You can configure one SMB server per NAS server. <br/> <br/> SMB, which stands for Server Message Block, is a protocol for sharing files and communications abstractions such as named pipes and mail slots between computers. Most usage of SMB involves computers running Microsoft Windows. Others vendors implementing SMB are Samba, MacOS.. SMB was also known as Common Internet File System (CIFS). <br/> <br/> An SMB server is created each time Windows shares are enabled on the NAS server. An SMB server could be created as a standalone server or as a server that belongs to a Windows domain (Active Directory). In that case, DNS must be enabled on the NAS server. The credentials of an administrator of the domain are required to join that domain. An NTP server must be defined also, to prevent authentication errors caused by unsynchronized clocks.  
      .DESCRIPTION
      Information about SMB server of a NAS server. You can configure one SMB server per NAS server. <br/> <br/> SMB, which stands for Server Message Block, is a protocol for sharing files and communications abstractions such as named pipes and mail slots between computers. Most usage of SMB involves computers running Microsoft Windows. Others vendors implementing SMB are Samba, MacOS.. SMB was also known as Common Internet File System (CIFS). <br/> <br/> An SMB server is created each time Windows shares are enabled on the NAS server. An SMB server could be created as a standalone server or as a server that belongs to a Windows domain (Active Directory). In that case, DNS must be enabled on the NAS server. The credentials of an administrator of the domain are required to join that domain. An NTP server must be defined also, to prevent authentication errors caused by unsynchronized clocks.  
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
      Get-UnitycifsServer

      Retrieve information about all UnitycifsServer
      .EXAMPLE
      Get-UnitycifsServer -ID 'id01'

      Retrieves information about a specific UnitycifsServer
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='Name',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnitycifsServer Name')]
    [String[]]$Name,
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnitycifsServer ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/cifsServer/instances' #URI
    $TypeName = 'UnitycifsServer'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


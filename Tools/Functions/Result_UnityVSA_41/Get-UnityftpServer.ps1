Function Get-UnityftpServer {

  <#
      .SYNOPSIS
      Information about the File Transfer Protocol (FTP) and Secure File Transfer Protocol (SFTP) servers of a NAS server. <br/> <br/> You can configure one FTP server and one SFTP server per NAS server. File Transfer Protocol (FTP) is a standard network protocol used to transfer files from one host to another host over a TCP-based network, such as the Internet. For secure transmission that encrypts the username, password, and content, FTP is secured with SSH (SFTP). <br/> <br/> You can activate an FTP server and SFTP server independently on each NAS server. The FTP and SFTP clients are authenticated using credentials defined on a Unix name server (such as an NIS server or a LDAP server) or a Windows domain. Windows user names need to be entered using the 'username@domain' or 'domain\username' formats. Each FTP and SFTP must have a home directory defined in the name server that must be accessible on the NAS server. FTP allows also clients to connect as anonymous users. <br/>  
      .DESCRIPTION
      Information about the File Transfer Protocol (FTP) and Secure File Transfer Protocol (SFTP) servers of a NAS server. <br/> <br/> You can configure one FTP server and one SFTP server per NAS server. File Transfer Protocol (FTP) is a standard network protocol used to transfer files from one host to another host over a TCP-based network, such as the Internet. For secure transmission that encrypts the username, password, and content, FTP is secured with SSH (SFTP). <br/> <br/> You can activate an FTP server and SFTP server independently on each NAS server. The FTP and SFTP clients are authenticated using credentials defined on a Unix name server (such as an NIS server or a LDAP server) or a Windows domain. Windows user names need to be entered using the 'username@domain' or 'domain\username' formats. Each FTP and SFTP must have a home directory defined in the name server that must be accessible on the NAS server. FTP allows also clients to connect as anonymous users. <br/>  
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
      Get-UnityftpServer

      Retrieve information about all UnityftpServer
      .EXAMPLE
      Get-UnityftpServer -ID 'id01'

      Retrieves information about a specific UnityftpServer
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnityftpServer ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/ftpServer/instances' #URI
    $TypeName = 'UnityftpServer'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


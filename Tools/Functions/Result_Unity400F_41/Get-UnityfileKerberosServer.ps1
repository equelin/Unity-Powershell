Function Get-UnityfileKerberosServer {

  <#
      .SYNOPSIS
      Information about the Kerberos service used by the storage system for secure connections. You can configure one Kerberos settings object per NAS server. <br/> Kerberos is a distributed authentication service designed to provide strong authentication with secret-key cryptography. It works on the basis of "tickets" that allow nodes communicating over a non-secure network to prove their identity in a secure manner. When configured to act as a secure NFS server, the NAS server uses the RPCSEC_GSS security framework and Kerberos authentication protocol to verify users and services. You can configure a secure NFS environment for a multiprotocol NAS server or one that supports Unix-only shares. In this environment, user access to NFS file systems is granted based on Kerberos principal names. <br/>  
      .DESCRIPTION
      Information about the Kerberos service used by the storage system for secure connections. You can configure one Kerberos settings object per NAS server. <br/> Kerberos is a distributed authentication service designed to provide strong authentication with secret-key cryptography. It works on the basis of "tickets" that allow nodes communicating over a non-secure network to prove their identity in a secure manner. When configured to act as a secure NFS server, the NAS server uses the RPCSEC_GSS security framework and Kerberos authentication protocol to verify users and services. You can configure a secure NFS environment for a multiprotocol NAS server or one that supports Unix-only shares. In this environment, user access to NFS file systems is granted based on Kerberos principal names. <br/>  
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
      Get-UnityfileKerberosServer

      Retrieve information about all UnityfileKerberosServer
      .EXAMPLE
      Get-UnityfileKerberosServer -ID 'id01'

      Retrieves information about a specific UnityfileKerberosServer
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnityfileKerberosServer ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/fileKerberosServer/instances' #URI
    $TypeName = 'UnityfileKerberosServer'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


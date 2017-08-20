Function Get-UnityldapServer {

  <#
      .SYNOPSIS
      Information about the Lightweight Directory Access Protocol (LDAP) server used by the storage system as an authentication authority for administrative users. You can configure one LDAP server. The system uses the LDAP settings for facilitating access control to Unisphere and the Unisphere CLI, but not for facilitating access control to storage resources. <br/> <br/> LDAP is an application protocol for querying and modifying directory services running on TCP/IP networks. LDAP provides central management for network authentication and authorization operations by helping to centralize user and group management across the network. Integrating the system into an existing LDAP environment provides a way to control user and user group access to the system through Unisphere or the Unisphere CLI. <br/> <br/> After you configure LDAP settings for the system, you can manage users and user groups within the context of an established LDAP directory structure. For example, you can assign access permissions to the Unisphere CLI that are based on existing users and groups. <br/> <br/>  
      .DESCRIPTION
      Information about the Lightweight Directory Access Protocol (LDAP) server used by the storage system as an authentication authority for administrative users. You can configure one LDAP server. The system uses the LDAP settings for facilitating access control to Unisphere and the Unisphere CLI, but not for facilitating access control to storage resources. <br/> <br/> LDAP is an application protocol for querying and modifying directory services running on TCP/IP networks. LDAP provides central management for network authentication and authorization operations by helping to centralize user and group management across the network. Integrating the system into an existing LDAP environment provides a way to control user and user group access to the system through Unisphere or the Unisphere CLI. <br/> <br/> After you configure LDAP settings for the system, you can manage users and user groups within the context of an established LDAP directory structure. For example, you can assign access permissions to the Unisphere CLI that are based on existing users and groups. <br/> <br/>  
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
      Get-UnityldapServer

      Retrieve information about all UnityldapServer
      .EXAMPLE
      Get-UnityldapServer -ID 'id01'

      Retrieves information about a specific UnityldapServer
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='Name',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnityldapServer Name')]
    [String[]]$Name,
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnityldapServer ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/ldapServer/instances' #URI
    $TypeName = 'UnityldapServer'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


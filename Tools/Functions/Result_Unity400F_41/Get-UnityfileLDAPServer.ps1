Function Get-UnityfileLDAPServer {

  <#
      .SYNOPSIS
      The LDAP settings object for the NAS Server. You can configure one LDAP settings object per NAS server. <br/> The Lightweight Directory Access Protocol (LDAP) is an application protocol for querying and modifying directory services running on TCP/IP networks. LDAP provides central management for network authentication and authorization operations by helping to centralize user and group management across the network. NAS server can use LDAP as a Unix Directory Service to map users, retrieve netgroups, and build a Unix credential. When an initial LDAP configuration is applied, the system checks for the type of LDAP server. It can be an Active Directory schema, iPlanet schema, or an RFC 2307 schema.  
      .DESCRIPTION
      The LDAP settings object for the NAS Server. You can configure one LDAP settings object per NAS server. <br/> The Lightweight Directory Access Protocol (LDAP) is an application protocol for querying and modifying directory services running on TCP/IP networks. LDAP provides central management for network authentication and authorization operations by helping to centralize user and group management across the network. NAS server can use LDAP as a Unix Directory Service to map users, retrieve netgroups, and build a Unix credential. When an initial LDAP configuration is applied, the system checks for the type of LDAP server. It can be an Active Directory schema, iPlanet schema, or an RFC 2307 schema.  
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
      Get-UnityfileLDAPServer

      Retrieve information about all UnityfileLDAPServer
      .EXAMPLE
      Get-UnityfileLDAPServer -ID 'id01'

      Retrieves information about a specific UnityfileLDAPServer
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnityfileLDAPServer ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/fileLDAPServer/instances' #URI
    $TypeName = 'UnityfileLDAPServer'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


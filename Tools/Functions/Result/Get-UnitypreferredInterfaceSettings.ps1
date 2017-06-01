Function Get-UnitypreferredInterfaceSettings {

  <#
      .SYNOPSIS
      The preferred interface of NAS server is an interface from which all the non-local outbound connections of this NAS server are initiated. The non-local connections are those which hosts can be accessed from this NAS server interfaces only via some router (gateway). <p/> The preferred interfaces for IPv4 and IPv6 are independent from each other. During the replication, the production interfaces could be activated and deactivated automatically, so the separate preferred interface settings are required for production and backup & DR testing interfaces. For each NAS server, the following preferred interface settings exist: <ol> <li>Production interfaces, IPv4.</li> <li>Production interfaces, IPv6.</li> <li>Backup & DR testing interfaces, IPv4.</li> <li>Backup & DR testing interfaces, IPv6.</li> </ol> <p/> Each of these settings could be set to the explicit interface. If it isn't set, corresponding interface will be selected automatically. <p/> The acting preferred interfaces, one for IPv4 and one for IPv6, are selected among active interfaces by the following rules, ordered by priority (highest first): <ol> <li>Manually selected interfaces have priority over automatically selected ones.</li> <li>Production interfaces have priority over backup and DR testing ones.</li> <li>The interface with the default gateway has priority over one not having one.</li> <li>From the otherwise equal priority interfaces, one with the most routes has the priority.</li> <li>From the otherwise equal priority interfaces, one with the minimal value of IP address (Sic!) has the priority.</li> </ol> <p/> <b>Note: </b>During the replication, on the destination side, only Backup & DR testing interfaces could be active. <p/> For the automatic selection, the interface re-selected each time any of this NAS interfaces or routes are changed. If the interface has been explicitly selected as preferred and then deleted, this type/class group setting (e.g. "Production/IPv6") gets reset to automatic selection. <p/> During the replication, on the destination side, only the production interfaces settings could be overridden. It is controlled by the single flag both for IPv4 and IPv6 interfaces. Note that this flag is independent from the "override" flag of the interface itself. If an interface is explicitly selected as preferred and then overridden, the interface is kept preferred. <p/> The acting preferred interfaces are marked by the corresponding property value, fileInterface.isPreferred == true. To get the list of the acting preferred interfaces of a NAS server, iterate its interface list checking the isPreferred property.  
      .DESCRIPTION
      The preferred interface of NAS server is an interface from which all the non-local outbound connections of this NAS server are initiated. The non-local connections are those which hosts can be accessed from this NAS server interfaces only via some router (gateway). <p/> The preferred interfaces for IPv4 and IPv6 are independent from each other. During the replication, the production interfaces could be activated and deactivated automatically, so the separate preferred interface settings are required for production and backup & DR testing interfaces. For each NAS server, the following preferred interface settings exist: <ol> <li>Production interfaces, IPv4.</li> <li>Production interfaces, IPv6.</li> <li>Backup & DR testing interfaces, IPv4.</li> <li>Backup & DR testing interfaces, IPv6.</li> </ol> <p/> Each of these settings could be set to the explicit interface. If it isn't set, corresponding interface will be selected automatically. <p/> The acting preferred interfaces, one for IPv4 and one for IPv6, are selected among active interfaces by the following rules, ordered by priority (highest first): <ol> <li>Manually selected interfaces have priority over automatically selected ones.</li> <li>Production interfaces have priority over backup and DR testing ones.</li> <li>The interface with the default gateway has priority over one not having one.</li> <li>From the otherwise equal priority interfaces, one with the most routes has the priority.</li> <li>From the otherwise equal priority interfaces, one with the minimal value of IP address (Sic!) has the priority.</li> </ol> <p/> <b>Note: </b>During the replication, on the destination side, only Backup & DR testing interfaces could be active. <p/> For the automatic selection, the interface re-selected each time any of this NAS interfaces or routes are changed. If the interface has been explicitly selected as preferred and then deleted, this type/class group setting (e.g. "Production/IPv6") gets reset to automatic selection. <p/> During the replication, on the destination side, only the production interfaces settings could be overridden. It is controlled by the single flag both for IPv4 and IPv6 interfaces. Note that this flag is independent from the "override" flag of the interface itself. If an interface is explicitly selected as preferred and then overridden, the interface is kept preferred. <p/> The acting preferred interfaces are marked by the corresponding property value, fileInterface.isPreferred == true. To get the list of the acting preferred interfaces of a NAS server, iterate its interface list checking the isPreferred property.  
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
      Get-UnitypreferredInterfaceSettings

      Retrieve information about all UnitypreferredInterfaceSettings
      .EXAMPLE
      Get-UnitypreferredInterfaceSettings -ID 'id01'

      Retrieves information about a specific UnitypreferredInterfaceSettings
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnitypreferredInterfaceSettings ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/preferredInterfaceSettings/instances' #URI
    $TypeName = 'UnitypreferredInterfaceSettings'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


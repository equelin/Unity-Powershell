Function Get-Unitytenant {

  <#
      .SYNOPSIS
      A tenant is a representation of a datacenter client, who uses an independent network structure and gets the independent and exclusive access to certain storage resources. On the storage array, it corresponds to a NAS server group with an independent IP addressing. At the moment, iSCSI and management resources do not support multi-tenant access. For each tenant a corresponding Linux network namespace is created. In the current design, traffic separation between the tenants is done by the VLANs. Each tenant reserves a group of VLANs, and each VLAN can belong to one tenant maximum. Every tenant gets a name and the Universally Unique Identifier (UUID). The UUID cannot be changed during the tenant life cycle. The asynchronous replication of the NAS servers is allowed only between the servers belonging to the tenants with the same UUID. The NAS servers and VLANs can still belong to no tenant. Such NAS servers and VLANs operate in the Linux base network namespace, together with management and iSCSI interfaces. The control stack of the system does not allow user to log in in the tenant administrator role. All the tenants, NAS servers and VLANs are managed from the single system administrator account. To allow this, the corresponding GUI and CLI modifications are made.  
      .DESCRIPTION
      A tenant is a representation of a datacenter client, who uses an independent network structure and gets the independent and exclusive access to certain storage resources. On the storage array, it corresponds to a NAS server group with an independent IP addressing. At the moment, iSCSI and management resources do not support multi-tenant access. For each tenant a corresponding Linux network namespace is created. In the current design, traffic separation between the tenants is done by the VLANs. Each tenant reserves a group of VLANs, and each VLAN can belong to one tenant maximum. Every tenant gets a name and the Universally Unique Identifier (UUID). The UUID cannot be changed during the tenant life cycle. The asynchronous replication of the NAS servers is allowed only between the servers belonging to the tenants with the same UUID. The NAS servers and VLANs can still belong to no tenant. Such NAS servers and VLANs operate in the Linux base network namespace, together with management and iSCSI interfaces. The control stack of the system does not allow user to log in in the tenant administrator role. All the tenants, NAS servers and VLANs are managed from the single system administrator account. To allow this, the corresponding GUI and CLI modifications are made.  
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
      Get-Unitytenant

      Retrieve information about all Unitytenant
      .EXAMPLE
      Get-Unitytenant -ID 'id01'

      Retrieves information about a specific Unitytenant
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='Name',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Unitytenant Name')]
    [String[]]$Name,
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Unitytenant ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/tenant/instances' #URI
    $TypeName = 'Unitytenant'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


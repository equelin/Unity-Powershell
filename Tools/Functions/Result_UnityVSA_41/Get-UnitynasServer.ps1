Function Get-UnitynasServer {

  <#
      .SYNOPSIS
      Information about the NAS server in the storage system. <br/> <br/> NAS Servers are software components used to transfer data and provide the connection ports for hosts to access file-level storage resources. NAS servers are independent from each other. <br/> <br/> NAS Servers access data on available drives making it available to network hosts via specific protocols (NFS/SMB/FTP/SFTP). Storage system supports NAS Servers for managing file-level storage resources, such as VMware NFS datastores or file systems. <br/> Before you can provision a file-level storage resource, a NAS Server must be created with the necessary sharing protocols enabled. When NAS Servers are created, you can specify the storage pool and owning SP - either SPA or SPB. <br/> In the storage systems, NAS Servers can leverage the Link Aggregation functionality to create a highly available environment. Once a link aggregated port group is available, you create or modify NAS Server network interfaces to leverage the available port group. Because NAS Servers are accessible through only one SP at a time, they will fail over to the other SP when there is an SP failure event.  
      .DESCRIPTION
      Information about the NAS server in the storage system. <br/> <br/> NAS Servers are software components used to transfer data and provide the connection ports for hosts to access file-level storage resources. NAS servers are independent from each other. <br/> <br/> NAS Servers access data on available drives making it available to network hosts via specific protocols (NFS/SMB/FTP/SFTP). Storage system supports NAS Servers for managing file-level storage resources, such as VMware NFS datastores or file systems. <br/> Before you can provision a file-level storage resource, a NAS Server must be created with the necessary sharing protocols enabled. When NAS Servers are created, you can specify the storage pool and owning SP - either SPA or SPB. <br/> In the storage systems, NAS Servers can leverage the Link Aggregation functionality to create a highly available environment. Once a link aggregated port group is available, you create or modify NAS Server network interfaces to leverage the available port group. Because NAS Servers are accessible through only one SP at a time, they will fail over to the other SP when there is an SP failure event.  
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
      Get-UnitynasServer

      Retrieve information about all UnitynasServer
      .EXAMPLE
      Get-UnitynasServer -ID 'id01'

      Retrieves information about a specific UnitynasServer
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='Name',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnitynasServer Name')]
    [String[]]$Name,
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnitynasServer ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/nasServer/instances' #URI
    $TypeName = 'UnitynasServer'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


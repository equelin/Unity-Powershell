Function Get-UnitystorageResource {

  <#
      .SYNOPSIS
      Information about storage resources in the storage system. <br/> <br/> A storage resource<b><i> </i></b>is a specific type of storage entity allocated in the storage system for a particular kind of host or application. The storage system provides the following types of storage resources: <ul> <li>LUNs</li> <li>Consistency groups</li> <li>File systems accessed via NFS and/or CIFS shares.</li> <li>VMware NFS datastores</li> <li>VMware VMFS datastores</li> <li>VVol (file)</li> <li>VVol (block)</li> </ul> All types of storage resource types can be divided into two major groups: <ul> <li>Block (or LUN based) storage resources: LUNs, consistency groups, VMware VMFS datastores, VVol (block).</li> <li>File system based storage resources: File systems, VMware NFS datastores, VVol (file).</li> </ul> In order to create a storage resource, there must be at least one pool configured on the system. For information about configuring pools, see the help topic for the pool. To provision file system based storage resource there must be at least one nasServer configured on the system.  
      .DESCRIPTION
      Information about storage resources in the storage system. <br/> <br/> A storage resource<b><i> </i></b>is a specific type of storage entity allocated in the storage system for a particular kind of host or application. The storage system provides the following types of storage resources: <ul> <li>LUNs</li> <li>Consistency groups</li> <li>File systems accessed via NFS and/or CIFS shares.</li> <li>VMware NFS datastores</li> <li>VMware VMFS datastores</li> <li>VVol (file)</li> <li>VVol (block)</li> </ul> All types of storage resource types can be divided into two major groups: <ul> <li>Block (or LUN based) storage resources: LUNs, consistency groups, VMware VMFS datastores, VVol (block).</li> <li>File system based storage resources: File systems, VMware NFS datastores, VVol (file).</li> </ul> In order to create a storage resource, there must be at least one pool configured on the system. For information about configuring pools, see the help topic for the pool. To provision file system based storage resource there must be at least one nasServer configured on the system.  
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
      Get-UnitystorageResource

      Retrieve information about all UnitystorageResource
      .EXAMPLE
      Get-UnitystorageResource -ID 'id01'

      Retrieves information about a specific UnitystorageResource
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='Name',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnitystorageResource Name')]
    [String[]]$Name,
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnitystorageResource ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/storageResource/instances' #URI
    $TypeName = 'UnitystorageResource'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


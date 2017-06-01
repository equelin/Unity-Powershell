Function Get-UnitynfsShare {

  <#
      .SYNOPSIS
      Information about Network File System (NFS) shares in the storage system. <br/> <br/> NFS shares use the NFS protocol to provide an access point for configured Linux/Unix hosts or IP subnets to access shared folder storage. NFS network shares are associated with an NFS shared folder. <br/> <br/> <b>Note: </b>To manage NFS shares for snapshots, use the operations for this resource type. To manage NFS shares for file systems and VMware NFS datastores, use the applicable operations for the storageResource resource type, as described in the help topic for that resource type.  
      .DESCRIPTION
      Information about Network File System (NFS) shares in the storage system. <br/> <br/> NFS shares use the NFS protocol to provide an access point for configured Linux/Unix hosts or IP subnets to access shared folder storage. NFS network shares are associated with an NFS shared folder. <br/> <br/> <b>Note: </b>To manage NFS shares for snapshots, use the operations for this resource type. To manage NFS shares for file systems and VMware NFS datastores, use the applicable operations for the storageResource resource type, as described in the help topic for that resource type.  
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
      Get-UnitynfsShare

      Retrieve information about all UnitynfsShare
      .EXAMPLE
      Get-UnitynfsShare -ID 'id01'

      Retrieves information about a specific UnitynfsShare
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='Name',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnitynfsShare Name')]
    [String[]]$Name,
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnitynfsShare ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/nfsShare/instances' #URI
    $TypeName = 'UnitynfsShare'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


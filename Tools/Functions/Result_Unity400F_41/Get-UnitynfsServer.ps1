Function Get-UnitynfsServer {

  <#
      .SYNOPSIS
      Information about the Network File System (NFS) servers used by the storage system. You can configure one NFS server per NAS server. At least one NFS share must be created before an NFS client can connect to the storage system resources. NFS servers support the NFSv3 and NFSv4 protocols. The default protocol is NFSv3.It is enabled when the NFS server is created and remains active until the NFS server is deleted.  
      .DESCRIPTION
      Information about the Network File System (NFS) servers used by the storage system. You can configure one NFS server per NAS server. At least one NFS share must be created before an NFS client can connect to the storage system resources. NFS servers support the NFSv3 and NFSv4 protocols. The default protocol is NFSv3.It is enabled when the NFS server is created and remains active until the NFS server is deleted.  
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
      Get-UnitynfsServer

      Retrieve information about all UnitynfsServer
      .EXAMPLE
      Get-UnitynfsServer -ID 'id01'

      Retrieves information about a specific UnitynfsServer
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='Name',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnitynfsServer Name')]
    [String[]]$Name,
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnitynfsServer ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/nfsServer/instances' #URI
    $TypeName = 'UnitynfsServer'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


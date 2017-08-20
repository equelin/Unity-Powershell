Function Get-UnitydhsmServer {

  <#
      .SYNOPSIS
      Information about the ASA/DHSM server of a NAS server. You can configure one ASA/DHSM server per NAS server. <br/> <br/> ASA stands for Advanced Storage Access. ASA allows VMware administrators to manage appropriately configured host configurations by taking advantage of advanced file operations that optimize NFS storage utilization. Once ASA is enabled on the NAS server, EMC's VSI Unified Storage Management tool can be utilized for the following: <ul> <li>Simplifying the process of creating NFS datastores,</li> <li>Compressing virtual machines in NFS datastores,</li> <li>Reducing the amount of storage consumed by virtual machines by using compression and Fast Clone technologies. The cloning functions include fast clones (thin copy/snaps) of Virtual Machine Disk (VMDF) files and full clones (full copy) of Virtual Machine Disk (VMDF) files.</li> </ul>  
      .DESCRIPTION
      Information about the ASA/DHSM server of a NAS server. You can configure one ASA/DHSM server per NAS server. <br/> <br/> ASA stands for Advanced Storage Access. ASA allows VMware administrators to manage appropriately configured host configurations by taking advantage of advanced file operations that optimize NFS storage utilization. Once ASA is enabled on the NAS server, EMC's VSI Unified Storage Management tool can be utilized for the following: <ul> <li>Simplifying the process of creating NFS datastores,</li> <li>Compressing virtual machines in NFS datastores,</li> <li>Reducing the amount of storage consumed by virtual machines by using compression and Fast Clone technologies. The cloning functions include fast clones (thin copy/snaps) of Virtual Machine Disk (VMDF) files and full clones (full copy) of Virtual Machine Disk (VMDF) files.</li> </ul>  
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
      Get-UnitydhsmServer

      Retrieve information about all UnitydhsmServer
      .EXAMPLE
      Get-UnitydhsmServer -ID 'id01'

      Retrieves information about a specific UnitydhsmServer
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='Name',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnitydhsmServer Name')]
    [String[]]$Name,
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnitydhsmServer ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/dhsmServer/instances' #URI
    $TypeName = 'UnitydhsmServer'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


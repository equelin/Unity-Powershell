Function Get-Unityfilesystem {

  <#
      .SYNOPSIS
      Information about the underlying file system associated with the file system and VMware NFS storage resources in the storage system.<br/> <br/> <b>Note:</b> To manage file systems and VMware NFS datastores, use the applicable operations for the storageResource object, as described in the help topic for that resource type.<br/>  
      .DESCRIPTION
      Information about the underlying file system associated with the file system and VMware NFS storage resources in the storage system.<br/> <br/> <b>Note:</b> To manage file systems and VMware NFS datastores, use the applicable operations for the storageResource object, as described in the help topic for that resource type.<br/>  
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
      Get-Unityfilesystem

      Retrieve information about all Unityfilesystem
      .EXAMPLE
      Get-Unityfilesystem -ID 'id01'

      Retrieves information about a specific Unityfilesystem
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='Name',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Unityfilesystem Name')]
    [String[]]$Name,
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Unityfilesystem ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/filesystem/instances' #URI
    $TypeName = 'Unityfilesystem'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


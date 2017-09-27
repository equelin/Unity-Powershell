Function Get-UnitycifsFilesystemParameters {

  <#
      .SYNOPSIS
      Settings for a SMB (also known as CIFS) file system.. <br/> <br/> This resource type is embedded in the storageResource resource type.  
      .DESCRIPTION
      Settings for a SMB (also known as CIFS) file system.. <br/> <br/> This resource type is embedded in the storageResource resource type.  
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
      Get-UnitycifsFilesystemParameters

      Retrieve information about all UnitycifsFilesystemParameters
      .EXAMPLE
      Get-UnitycifsFilesystemParameters -ID 'id01'

      Retrieves information about a specific UnitycifsFilesystemParameters
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnitycifsFilesystemParameters ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/cifsFilesystemParameters/instances' #URI
    $TypeName = 'UnitycifsFilesystemParameters'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


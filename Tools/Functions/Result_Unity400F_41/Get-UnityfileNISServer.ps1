Function Get-UnityfileNISServer {

  <#
      .SYNOPSIS
      The NIS settings object for the NAS Server. You can configure one NIS settings object per NAS server. <br/> The Network Information Service (NIS) consists of a directory service protocol for maintaining and distributing system configuration information, such as user and group information, hostnames etc.  
      .DESCRIPTION
      The NIS settings object for the NAS Server. You can configure one NIS settings object per NAS server. <br/> The Network Information Service (NIS) consists of a directory service protocol for maintaining and distributing system configuration information, such as user and group information, hostnames etc.  
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
      Get-UnityfileNISServer

      Retrieve information about all UnityfileNISServer
      .EXAMPLE
      Get-UnityfileNISServer -ID 'id01'

      Retrieves information about a specific UnityfileNISServer
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnityfileNISServer ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/fileNISServer/instances' #URI
    $TypeName = 'UnityfileNISServer'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


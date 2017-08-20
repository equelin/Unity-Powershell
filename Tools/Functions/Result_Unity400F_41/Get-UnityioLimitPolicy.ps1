Function Get-UnityioLimitPolicy {

  <#
      .SYNOPSIS
      Set of I/O limit rules that you can apply to a storage resource. On GUI and CLI, ioLimitPolicy and ioLimitRule are combined for now since we only support one I/O limit rule per I/O limit policy.  
      .DESCRIPTION
      Set of I/O limit rules that you can apply to a storage resource. On GUI and CLI, ioLimitPolicy and ioLimitRule are combined for now since we only support one I/O limit rule per I/O limit policy.  
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
      Get-UnityioLimitPolicy

      Retrieve information about all UnityioLimitPolicy
      .EXAMPLE
      Get-UnityioLimitPolicy -ID 'id01'

      Retrieves information about a specific UnityioLimitPolicy
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='Name',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnityioLimitPolicy Name')]
    [String[]]$Name,
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnityioLimitPolicy ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/ioLimitPolicy/instances' #URI
    $TypeName = 'UnityioLimitPolicy'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


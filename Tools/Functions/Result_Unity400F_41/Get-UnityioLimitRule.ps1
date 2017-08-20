Function Get-UnityioLimitRule {

  <#
      .SYNOPSIS
      (DEPRECATED)Conditions under which the storage system applies I/O limits. On GUI and CLI, ioLimitPolicy and ioLimitRule are combined for now since we only support one I/O limit rule per I/O limit policy.  
      .DESCRIPTION
      (DEPRECATED)Conditions under which the storage system applies I/O limits. On GUI and CLI, ioLimitPolicy and ioLimitRule are combined for now since we only support one I/O limit rule per I/O limit policy.  
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
      Get-UnityioLimitRule

      Retrieve information about all UnityioLimitRule
      .EXAMPLE
      Get-UnityioLimitRule -ID 'id01'

      Retrieves information about a specific UnityioLimitRule
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='Name',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnityioLimitRule Name')]
    [String[]]$Name,
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnityioLimitRule ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/ioLimitRule/instances' #URI
    $TypeName = 'UnityioLimitRule'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


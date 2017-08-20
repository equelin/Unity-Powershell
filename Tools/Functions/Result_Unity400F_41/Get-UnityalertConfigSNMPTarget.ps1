Function Get-UnityalertConfigSNMPTarget {

  <#
      .SYNOPSIS
      Information about the Simple Network Management Protocol (SNMP) destinations used by alerts. <br/> The system uses SNMP to transfer system alerts as traps to an SNMP destination host. Traps are asynchronous messages that notify the SNMP destination when system and user events occur.  
      .DESCRIPTION
      Information about the Simple Network Management Protocol (SNMP) destinations used by alerts. <br/> The system uses SNMP to transfer system alerts as traps to an SNMP destination host. Traps are asynchronous messages that notify the SNMP destination when system and user events occur.  
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
      Get-UnityalertConfigSNMPTarget

      Retrieve information about all UnityalertConfigSNMPTarget
      .EXAMPLE
      Get-UnityalertConfigSNMPTarget -ID 'id01'

      Retrieves information about a specific UnityalertConfigSNMPTarget
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='Name',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnityalertConfigSNMPTarget Name')]
    [String[]]$Name,
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnityalertConfigSNMPTarget ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/alertConfigSNMPTarget/instances' #URI
    $TypeName = 'UnityalertConfigSNMPTarget'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


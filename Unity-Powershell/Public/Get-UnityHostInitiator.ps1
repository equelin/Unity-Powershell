Function Get-UnityHostInitiator {

  <#
      .SYNOPSIS
      View details about host initiators.
      .DESCRIPTION
      View details about host initiators on the system.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quélin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specifies an UnitySession Object.
      .PARAMETER ID
      Specifies the object ID.
      .PARAMETER PortWWN
      Specifies the port WWN.
      .EXAMPLE
      Get-UnityHostInitiator

      Retrieve information about all hosts

      .EXAMPLE
      Get-UnityHostInitiator -ID 'Host_67'

      Retrieves information about host initiator named 'Host_67'
  #>

  [CmdletBinding(DefaultParameterSetName="ID")]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName="ID",ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Host Initiator ID')]
    [String[]]$ID,
    [Parameter(Mandatory = $false,ParameterSetName="PortWwn",ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Initiator Port WWN')]
    [String[]]$PortWWN    
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/hostInitiator/instances' #URI
    $TypeName = 'UnityHostInitiator'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function
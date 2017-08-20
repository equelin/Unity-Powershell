Function Get-UnitymoveSession {

  <#
      .SYNOPSIS
      Information about movesession. <br/> <br/> A customer environment is often ever-changing, and as a result the ability to deliver business continuity and flexibility is paramount. The new local LUN migration feature address this concern, by adding the ability to move LUNs and Consistency Groups between Pools on a system. Local LUN migration can be used to rebalance storage resources across Pools when customer activity changes and an individual Pool's usage becomes oversaturated. Another use case for local LUN migration is to provide LUNs with a destination when a Pool is to be decommissioned. By leveraging Unity's Transparent Data Transfer (TDX) engine, host access remains fully online during the migration session.  
      .DESCRIPTION
      Information about movesession. <br/> <br/> A customer environment is often ever-changing, and as a result the ability to deliver business continuity and flexibility is paramount. The new local LUN migration feature address this concern, by adding the ability to move LUNs and Consistency Groups between Pools on a system. Local LUN migration can be used to rebalance storage resources across Pools when customer activity changes and an individual Pool's usage becomes oversaturated. Another use case for local LUN migration is to provide LUNs with a destination when a Pool is to be decommissioned. By leveraging Unity's Transparent Data Transfer (TDX) engine, host access remains fully online during the migration session.  
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
      Get-UnitymoveSession

      Retrieve information about all UnitymoveSession
      .EXAMPLE
      Get-UnitymoveSession -ID 'id01'

      Retrieves information about a specific UnitymoveSession
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnitymoveSession ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/moveSession/instances' #URI
    $TypeName = 'UnitymoveSession'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


Function Get-UnityFastVP {

  <#
      .SYNOPSIS
      System FAST VP settings. FAST VP allows performing automatic data relocation between tiers and rebalancing within a tier to improve storage performance. Currently there three types of relocations supported: <br/> <li>Scheduled relocations</li> <li>Manual relocations</li> <li>Rebalancing</li> <br/> Scheduled relocations are started according the schedule defined in this resource. Individual pools can be included to or excluded from the scheduled relocation process. <br/> Manual relocations can be performed on demand for each particular pool. <br/> Rebalancing is performed automatically on a pool extend event. <br/> The FAST VP object represents the status of scheduled relocation processes and allows to view or modify the scheduled relocation parameters. It also provides a means to pause or resume all the FAST VP relocation and rebalancing processes currently running on the system.  
      .DESCRIPTION
      System FAST VP settings. FAST VP allows performing automatic data relocation between tiers and rebalancing within a tier to improve storage performance. Currently there three types of relocations supported: <br/> <li>Scheduled relocations</li> <li>Manual relocations</li> <li>Rebalancing</li> <br/> Scheduled relocations are started according the schedule defined in this resource. Individual pools can be included to or excluded from the scheduled relocation process. <br/> Manual relocations can be performed on demand for each particular pool. <br/> Rebalancing is performed automatically on a pool extend event. <br/> The FAST VP object represents the status of scheduled relocation processes and allows to view or modify the scheduled relocation parameters. It also provides a means to pause or resume all the FAST VP relocation and rebalancing processes currently running on the system.  
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
      Get-UnityFastVP

      Retrieve information about all UnityfastVP
      .EXAMPLE
      Get-UnityFastVP -ID 'id01'

      Retrieves information about a specific UnityfastVP
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnityfastVP ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/fastVP/instances' #URI
    $TypeName = 'UnityfastVP'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


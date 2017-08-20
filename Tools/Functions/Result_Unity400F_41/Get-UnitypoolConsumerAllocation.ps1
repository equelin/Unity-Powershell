Function Get-UnitypoolConsumerAllocation {

  <#
      .SYNOPSIS
      poolConsumerAllocation class represents size of pool's space allocated by the consumer (storageResources or nasServers) inside the pool. Most of consumers are always wholly allocated in one and only one storage pool. The only exception is consistencyGroup storage resource that can contain different LUNs that reside in different pools.  
      .DESCRIPTION
      poolConsumerAllocation class represents size of pool's space allocated by the consumer (storageResources or nasServers) inside the pool. Most of consumers are always wholly allocated in one and only one storage pool. The only exception is consistencyGroup storage resource that can contain different LUNs that reside in different pools.  
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
      Get-UnitypoolConsumerAllocation

      Retrieve information about all UnitypoolConsumerAllocation
      .EXAMPLE
      Get-UnitypoolConsumerAllocation -ID 'id01'

      Retrieves information about a specific UnitypoolConsumerAllocation
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnitypoolConsumerAllocation ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/poolConsumerAllocation/instances' #URI
    $TypeName = 'UnitypoolConsumerAllocation'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


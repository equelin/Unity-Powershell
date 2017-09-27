Function Get-UnitystorageTierConfiguration {

  <#
      .SYNOPSIS
      Possible disk selections for a storage tier, given a specified storage tier type, RAID type, and stripe width. <br/> <br/> Use this resource type, along with the pool, diskGroup, and storageTier resource types, to create custom pools. For more information, see the help topic for the pool resource type.  
      .DESCRIPTION
      Possible disk selections for a storage tier, given a specified storage tier type, RAID type, and stripe width. <br/> <br/> Use this resource type, along with the pool, diskGroup, and storageTier resource types, to create custom pools. For more information, see the help topic for the pool resource type.  
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
      Get-UnitystorageTierConfiguration

      Retrieve information about all UnitystorageTierConfiguration
      .EXAMPLE
      Get-UnitystorageTierConfiguration -ID 'id01'

      Retrieves information about a specific UnitystorageTierConfiguration
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnitystorageTierConfiguration ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/storageTierConfiguration/instances' #URI
    $TypeName = 'UnitystorageTierConfiguration'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


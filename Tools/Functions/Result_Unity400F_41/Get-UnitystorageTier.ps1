Function Get-UnitystorageTier {

  <#
      .SYNOPSIS
      Set of possible RAID configurations that a storage tier can support. (A storage tier is the collection of all disks of a particular type on the storage system.) For example, if you have 11 disks in a tier, you can support R5 (4+1), R5 (8+1), but not R5(12+1). <br/> <br/> Use this resource type to create custom pools. For more information, see the help topic for the pool resource type. <br/> <br/>  
      .DESCRIPTION
      Set of possible RAID configurations that a storage tier can support. (A storage tier is the collection of all disks of a particular type on the storage system.) For example, if you have 11 disks in a tier, you can support R5 (4+1), R5 (8+1), but not R5(12+1). <br/> <br/> Use this resource type to create custom pools. For more information, see the help topic for the pool resource type. <br/> <br/>  
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
      Get-UnitystorageTier

      Retrieve information about all UnitystorageTier
      .EXAMPLE
      Get-UnitystorageTier -ID 'id01'

      Retrieves information about a specific UnitystorageTier
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnitystorageTier ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/storageTier/instances' #URI
    $TypeName = 'UnitystorageTier'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


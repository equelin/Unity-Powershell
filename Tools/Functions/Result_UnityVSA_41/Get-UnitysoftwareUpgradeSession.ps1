Function Get-UnitysoftwareUpgradeSession {

  <#
      .SYNOPSIS
      Information about a storage system upgrade session. <br/> <br/> Create an upgrade session to upgrade the system software or view existing upgrade sessions. The upgrade session installs an upgrade candidate file that was uploaded to the system. Download the latest upgrade candidate from EMC Online Support website. Use the CLI to upload the upgrade candidate to the system before creating the upgrade session. For information, see the <i>Unisphere CLI User Guide</i>. <br/> <br/> The latest software upgrade candidate contains all available hot fixes. If you have applied hot fixes to your system, the hot fixes are included in the latest upgrade candidate. <br/> <br/> <b>Note: </b>All system components must be healthy prior to upgrading the system software. If any system components are degraded, the software update will fail.  
      .DESCRIPTION
      Information about a storage system upgrade session. <br/> <br/> Create an upgrade session to upgrade the system software or view existing upgrade sessions. The upgrade session installs an upgrade candidate file that was uploaded to the system. Download the latest upgrade candidate from EMC Online Support website. Use the CLI to upload the upgrade candidate to the system before creating the upgrade session. For information, see the <i>Unisphere CLI User Guide</i>. <br/> <br/> The latest software upgrade candidate contains all available hot fixes. If you have applied hot fixes to your system, the hot fixes are included in the latest upgrade candidate. <br/> <br/> <b>Note: </b>All system components must be healthy prior to upgrading the system software. If any system components are degraded, the software update will fail.  
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
      Get-UnitysoftwareUpgradeSession

      Retrieve information about all UnitysoftwareUpgradeSession
      .EXAMPLE
      Get-UnitysoftwareUpgradeSession -ID 'id01'

      Retrieves information about a specific UnitysoftwareUpgradeSession
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnitysoftwareUpgradeSession ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/softwareUpgradeSession/instances' #URI
    $TypeName = 'UnitysoftwareUpgradeSession'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


Function Get-Unitypool {

  <#
      .SYNOPSIS
      Information about pools in the storage system. <br/> <br/> <b>Creating pools using Quick Start mode</b> <br/> <br/> You can use Quick Start mode to create system recommended pools based on the type and availability of disks in the system. In Quick Start mode, the system recommends separate pools for different disk types and uses default RAID configurations for the disks. A pool configured in Quick Start mode has only one tier. <br/> <br/> Quick Start mode is available when both of these conditions are met: <ul> <li>No pools exist on the system.</li> <li>The system is not licensed for FAST VP or FAST Cache.</li> </ul> <br/> To create pools using Quick Start mode, follow these steps: <ol> <li>Run POST <font color=#0f0f0f>api/types/pool/action/recommendAutoConfiguration. </font> <font color=#0f0f0f><br/></font> <font color=#0f0f0f><br/></font> <font color=#0f0f0f>The response body contains a set of poolSetting instances.</li></font> <font color=#0f0f0f><br/></font> <font color=#0f0f0f><li value=2>For each poolSetting instance returned in Step 1, run POST /api/types/pool/instances with the following arguments, using values obtained from the poolSetting instance:</li></font> <ul> <li>addRaidGroupParameters : [{dskGroup : poolSetting.storageConfiguration.possibleStorageConfigurations.diskGroup,</li> <li>numDisks : poolSetting.storageConfiguration.possibleStorageConfigurations.raidGroupConfigurations.diskCount,</li> <li>raidType : poolSetting.storageConfiguration.raidType,</li> <li>stripeWidth : poolSetting.storageConfiguration.possibleStorageConfigurations.raidGroupConfigurations.stripeWidths},...]</li> </ul> </ol> Pool creation examples: <br/> Simple pool with one RAID5 4+1: <br/> POST /api/types/pool/instances <br/> {"name" : "PerformancePool",<br/> "addRaidGroupParameters" : [<br/> {"dskGroup" : {"id" : dg_15},<br/> "numDisks" : 5,<br/> "raidType" : 1,<br/> "stripeWidth" : 5}<br/> ]<br/> }<br/> <br/> Pool with raid group RAID10 1+1: <br/> {"name" : "SysDefPool00",<br/> "description" : "The pool is created with RAID10(1+1)",<br/> "addRaidGroupParameters" : [<br/> {"dskGroup" : {"id" : "dg_16"},<br/> "numDisks" : 2,<br/> "raidType" : 7,<br/> "stripeWidth" : 2}<br/> ]<br/> }<br/> <br/> <br/>  
      .DESCRIPTION
      Information about pools in the storage system. <br/> <br/> <b>Creating pools using Quick Start mode</b> <br/> <br/> You can use Quick Start mode to create system recommended pools based on the type and availability of disks in the system. In Quick Start mode, the system recommends separate pools for different disk types and uses default RAID configurations for the disks. A pool configured in Quick Start mode has only one tier. <br/> <br/> Quick Start mode is available when both of these conditions are met: <ul> <li>No pools exist on the system.</li> <li>The system is not licensed for FAST VP or FAST Cache.</li> </ul> <br/> To create pools using Quick Start mode, follow these steps: <ol> <li>Run POST <font color=#0f0f0f>api/types/pool/action/recommendAutoConfiguration. </font> <font color=#0f0f0f><br/></font> <font color=#0f0f0f><br/></font> <font color=#0f0f0f>The response body contains a set of poolSetting instances.</li></font> <font color=#0f0f0f><br/></font> <font color=#0f0f0f><li value=2>For each poolSetting instance returned in Step 1, run POST /api/types/pool/instances with the following arguments, using values obtained from the poolSetting instance:</li></font> <ul> <li>addRaidGroupParameters : [{dskGroup : poolSetting.storageConfiguration.possibleStorageConfigurations.diskGroup,</li> <li>numDisks : poolSetting.storageConfiguration.possibleStorageConfigurations.raidGroupConfigurations.diskCount,</li> <li>raidType : poolSetting.storageConfiguration.raidType,</li> <li>stripeWidth : poolSetting.storageConfiguration.possibleStorageConfigurations.raidGroupConfigurations.stripeWidths},...]</li> </ul> </ol> Pool creation examples: <br/> Simple pool with one RAID5 4+1: <br/> POST /api/types/pool/instances <br/> {"name" : "PerformancePool",<br/> "addRaidGroupParameters" : [<br/> {"dskGroup" : {"id" : dg_15},<br/> "numDisks" : 5,<br/> "raidType" : 1,<br/> "stripeWidth" : 5}<br/> ]<br/> }<br/> <br/> Pool with raid group RAID10 1+1: <br/> {"name" : "SysDefPool00",<br/> "description" : "The pool is created with RAID10(1+1)",<br/> "addRaidGroupParameters" : [<br/> {"dskGroup" : {"id" : "dg_16"},<br/> "numDisks" : 2,<br/> "raidType" : 7,<br/> "stripeWidth" : 2}<br/> ]<br/> }<br/> <br/> <br/>  
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
      Get-Unitypool

      Retrieve information about all Unitypool
      .EXAMPLE
      Get-Unitypool -ID 'id01'

      Retrieves information about a specific Unitypool
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='Name',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Unitypool Name')]
    [String[]]$Name,
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Unitypool ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/pool/instances' #URI
    $TypeName = 'Unitypool'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


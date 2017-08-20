Function Get-UnityrpChapSettings {

  <#
      .SYNOPSIS
      CHAP accounts management for RPA cluster. RPA iSCSI ports act as initiators and log into storage targets, meanwhile, storage iSCSI ports act as initiators and log into RPA targets as well. For security reason, forward CHAP is supported on both directions. Outgoing forward CHAP account is used by storage ports to log into RPAs and incoming foward CHAP account is used by storage to authenticate RPA initiators. However, for now incoming forward account is managed by iscsiSettings and it will be moved here in later releases.  
      .DESCRIPTION
      CHAP accounts management for RPA cluster. RPA iSCSI ports act as initiators and log into storage targets, meanwhile, storage iSCSI ports act as initiators and log into RPA targets as well. For security reason, forward CHAP is supported on both directions. Outgoing forward CHAP account is used by storage ports to log into RPAs and incoming foward CHAP account is used by storage to authenticate RPA initiators. However, for now incoming forward account is managed by iscsiSettings and it will be moved here in later releases.  
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
      Get-UnityrpChapSettings

      Retrieve information about all UnityrpChapSettings
      .EXAMPLE
      Get-UnityrpChapSettings -ID 'id01'

      Retrieves information about a specific UnityrpChapSettings
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='Name',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnityrpChapSettings Name')]
    [String[]]$Name,
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnityrpChapSettings ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/rpChapSettings/instances' #URI
    $TypeName = 'UnityrpChapSettings'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


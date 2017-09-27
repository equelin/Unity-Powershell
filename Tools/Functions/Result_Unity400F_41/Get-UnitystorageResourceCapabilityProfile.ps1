Function Get-UnityStorageResourceCapabilityProfile {

  <#
      .SYNOPSIS
      An association between a capability profile and a datastore-type storage resource, with capacity usage information about virtual volumes provisioned accordingly.  
      .DESCRIPTION
      An association between a capability profile and a datastore-type storage resource, with capacity usage information about virtual volumes provisioned accordingly.  
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
      Get-UnityStorageResourceCapabilityProfile

      Retrieve information about all UnitystorageResourceCapabilityProfile
      .EXAMPLE
      Get-UnityStorageResourceCapabilityProfile -ID 'id01'

      Retrieves information about a specific UnitystorageResourceCapabilityProfile
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnitystorageResourceCapabilityProfile ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/storageResourceCapabilityProfile/instances' #URI
    $TypeName = 'UnitystorageResourceCapabilityProfile'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


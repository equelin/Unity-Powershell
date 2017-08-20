Function Get-UnityresourceRef {

  <#
      .SYNOPSIS
      This is used to contain a reference to an instance where the class may vary. <Eng> A property or arg of this type, if mapped to an OSLS property/arg, means that the OSLS value is the instance id (instance name) of the target object. This can be looked up to find the class and id for this interface. </Eng>  
      .DESCRIPTION
      This is used to contain a reference to an instance where the class may vary. <Eng> A property or arg of this type, if mapped to an OSLS property/arg, means that the OSLS value is the instance id (instance name) of the target object. This can be looked up to find the class and id for this interface. </Eng>  
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
      Get-UnityresourceRef

      Retrieve information about all UnityresourceRef
      .EXAMPLE
      Get-UnityresourceRef -ID 'id01'

      Retrieves information about a specific UnityresourceRef
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnityresourceRef ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/resourceRef/instances' #URI
    $TypeName = 'UnityresourceRef'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


Function Get-UnityFastVPParameters {

  <#
      .SYNOPSIS
      FAST VP settings for the storage resource. <br/> (Applies if FAST VP is supported on the system and the corresponding license is installed.) <br/> This resource type is embedded in the storageResource resource type.  
      .DESCRIPTION
      FAST VP settings for the storage resource. <br/> (Applies if FAST VP is supported on the system and the corresponding license is installed.) <br/> This resource type is embedded in the storageResource resource type.  
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
      Get-UnityFastVPParameters

      Retrieve information about all UnityfastVPParameters
      .EXAMPLE
      Get-UnityFastVPParameters -ID 'id01'

      Retrieves information about a specific UnityfastVPParameters
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnityfastVPParameters ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/fastVPParameters/instances' #URI
    $TypeName = 'UnityfastVPParameters'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


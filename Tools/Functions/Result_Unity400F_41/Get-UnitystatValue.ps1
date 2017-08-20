Function Get-UnitystatValue {

  <#
      .SYNOPSIS
      A statValue object contains one real-time sample of a single metric. Its JSON representation is the following: statValue {} { values } values pair pair , values pair string : value value float statValue The string in a pair is the ID of an object. The value is the metric value for that object.  
      .DESCRIPTION
      A statValue object contains one real-time sample of a single metric. Its JSON representation is the following: statValue {} { values } values pair pair , values pair string : value value float statValue The string in a pair is the ID of an object. The value is the metric value for that object.  
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
      Get-UnitystatValue

      Retrieve information about all UnitystatValue
      .EXAMPLE
      Get-UnitystatValue -ID 'id01'

      Retrieves information about a specific UnitystatValue
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnitystatValue ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/statValue/instances' #URI
    $TypeName = 'UnitystatValue'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


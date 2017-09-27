Function Get-UnitysupportProxy {

  <#
      .SYNOPSIS
      Proxy Server settings. <p/> A proxy server is a server that acts as an intermediary for requests from clients seeking resources from other servers. <p/> The system uses the proxy server (if it's enabled) to access EMC web services such as authenticate support credential, get technical advisories, etc.  
      .DESCRIPTION
      Proxy Server settings. <p/> A proxy server is a server that acts as an intermediary for requests from clients seeking resources from other servers. <p/> The system uses the proxy server (if it's enabled) to access EMC web services such as authenticate support credential, get technical advisories, etc.  
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
      Get-UnitysupportProxy

      Retrieve information about all UnitysupportProxy
      .EXAMPLE
      Get-UnitysupportProxy -ID 'id01'

      Retrieves information about a specific UnitysupportProxy
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='Name',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnitysupportProxy Name')]
    [String[]]$Name,
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnitysupportProxy ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/supportProxy/instances' #URI
    $TypeName = 'UnitysupportProxy'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


Function Get-UnityCIFSShare {

  <#
      .SYNOPSIS
      Queries the EMC Unity array to retrieve informations about CIFS Share.
      .DESCRIPTION
      Queries the EMC Unity array to retrieve informations about CIFS Share.
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
      Get-UnityCIFSShare

      Retrieve information about CIFS Share
      .EXAMPLE
      Get-UnityCIFSShare -Name 'SHARE01'

      Retrieves information about CIFS Share named SHARE01
  #>

  [CmdletBinding(DefaultParameterSetName="Name")]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName="Name",ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'CIFS Share Name')]
    [String[]]$Name,
    [Parameter(Mandatory = $false,ParameterSetName="ID",ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'CIFS Share ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/cifsShare/instances' #URI
    $TypeName = 'UnityCIFSShare'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function

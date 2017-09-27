Function Get-UnitypoolFASTVP {

  <#
      .SYNOPSIS
      (Applies if FAST VP is supported on the system and the corresponding license is installed.) FAST VP settings for the pool associated with this embedded type. <br/>  
      .DESCRIPTION
      (Applies if FAST VP is supported on the system and the corresponding license is installed.) FAST VP settings for the pool associated with this embedded type. <br/>  
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
      Get-UnitypoolFASTVP

      Retrieve information about all UnitypoolFASTVP
      .EXAMPLE
      Get-UnitypoolFASTVP -ID 'id01'

      Retrieves information about a specific UnitypoolFASTVP
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnitypoolFASTVP ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/poolFASTVP/instances' #URI
    $TypeName = 'UnitypoolFASTVP'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


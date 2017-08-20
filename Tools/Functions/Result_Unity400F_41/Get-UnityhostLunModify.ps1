Function Get-UnityhostLunModify {

  <#
      .SYNOPSIS
      Parameters used for modifying the HLU of a Host LUN. <br/> <br/> This embedded class type is passed to the ModifyHostLUNs method of the host object.  
      .DESCRIPTION
      Parameters used for modifying the HLU of a Host LUN. <br/> <br/> This embedded class type is passed to the ModifyHostLUNs method of the host object.  
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
      Get-UnityhostLunModify

      Retrieve information about all UnityhostLunModify
      .EXAMPLE
      Get-UnityhostLunModify -ID 'id01'

      Retrieves information about a specific UnityhostLunModify
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnityhostLunModify ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/hostLunModify/instances' #URI
    $TypeName = 'UnityhostLunModify'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


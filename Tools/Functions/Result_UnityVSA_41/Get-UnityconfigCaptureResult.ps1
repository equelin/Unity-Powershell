Function Get-UnityconfigCaptureResult {

  <#
      .SYNOPSIS
      Information about Configuration Capture results in the storage system. <br/> <br/> Configuration Capture is a service feature which creates a snapshot of the current system configuration. It captures all of the necessary data for business intelligence analysis, helping diagnose issues. <br/> <br/>  
      .DESCRIPTION
      Information about Configuration Capture results in the storage system. <br/> <br/> Configuration Capture is a service feature which creates a snapshot of the current system configuration. It captures all of the necessary data for business intelligence analysis, helping diagnose issues. <br/> <br/>  
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
      Get-UnityconfigCaptureResult

      Retrieve information about all UnityconfigCaptureResult
      .EXAMPLE
      Get-UnityconfigCaptureResult -ID 'id01'

      Retrieves information about a specific UnityconfigCaptureResult
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='Name',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnityconfigCaptureResult Name')]
    [String[]]$Name,
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnityconfigCaptureResult ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/configCaptureResult/instances' #URI
    $TypeName = 'UnityconfigCaptureResult'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


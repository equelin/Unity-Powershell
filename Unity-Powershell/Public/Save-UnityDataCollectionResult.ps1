Function Save-UnityDataCollectionResult {

  <#
      .SYNOPSIS
      Generate and download data collection results
      .DESCRIPTION
      Generate and download data collection results.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specifies an UnitySession Object.
      .PARAMETER dataCollectionProfile
      The profile used to collect service information.
      .PARAMETER Path
      Specifies where to store downloaded Data Collection Results
      .PARAMETER Compress
      Specifies if you want to compress the downloaded file
      .EXAMPLE
      Save-UnityDataCollectionResult -dataCollectionProfile 'default' -Path 'C:' -Compress

      Generate a default data collection and download it in C: as a ZIP file.
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,HelpMessage = 'The profile used to collect service information.')]
    [DataCollectionProfileEnum]$dataCollectionProfile = 'Default',
    [Parameter(Mandatory = $false,HelpMessage = 'Zip the downloaded file(s)')]
    [Switch]$Compress,
    [Parameter(Mandatory = $false,HelpMessage = 'Download path')]
    [validatescript({Test-Path $_})]
    [String]$Path ="."
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand.Name)] Executing function"
    Write-Debug -Message "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
    Write-Debug -Message "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      $ParametersUnityserviceAction = @{
        session = $Sess
        dataCollection = $True
        DataCollectionProfile = $dataCollectionProfile
      }

      $ParametersUnityDataCollectionResult = @{
        session = $Sess
        Download = $True
        Path = $Path
      }

      If ($PSBoundParameters.ContainsKey('Compress')) {
        $ParametersUnityDataCollectionResult['compress'] = $True
      }

      If ($pscmdlet.ShouldProcess($Sess.Name,"Generate and download data collection results")) {
        (Set-UnityserviceAction @ParametersUnityserviceAction).id | Get-UnityDataCollectionResult @ParametersUnityDataCollectionResult
      }
    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


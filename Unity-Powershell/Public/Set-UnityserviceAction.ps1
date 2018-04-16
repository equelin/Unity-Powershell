Function Set-UnityServiceAction {

  <#
      .SYNOPSIS
      Services the system.
      .DESCRIPTION
      Services the system. Possible actions: 
        - Collect Service Information (dataCollection): Collect information about the storage system and save it to a file. Your service provider can use the collected information to analyze the storage system. 
        - Save Configuration (configCapture): Save details about the configuration settings on the storage system to a file. Your service provider can use this file to assist you with reconfiguring your system after a major system failure or a system reinitialization. 
        - Restart Management Software (restartMGT): Restart the management software to resolve connection problems between the system and Unisphere. 
        - Reinitialize (reinitialize): Reset the storage system to the original factory settings. Both SPs must be installed and operating normally be in Service Mode. 
        - Change Service Password (changeServicePassword): Change the service password for accessing the Service System page. 
        - Shut Down System (shutdownSystem): The system shut down and power cycle procedures will attempt to resolve problems with your storage system that could not be resolved by rebooting or reimaging the SP. 
        - Disable SSH/Enable SSH (changeSSHStatus): Disable the Secure Shell (SSH) protocol to block SSH access to the system, or enable the Secure Shell (SSH) protocol to enable access to the system. 
        - Enter Service Mode (enterServiceModeSPA, enterServiceModeSPB): Stop I/O on the SP so that the SP can enter service mode safely. 
        - Reboot (rebootSPA, rebootSPB): Reboot the selected SP. Use this service action to attempt to resolve minor problems related to system software or SP hardware components. 
        - Reimage (rebootSPA, rebootSPB): Reimage the selected SP. Reimaging analyzes the system software on the SP and attempts to correct any problems automatically. 
        - Reset and Hold(resetAndHoldSPA, resetAndHoldSPB): Reset and hold the selected SP. Use this service task to attempt to reset and hold the SP, so that users can replace the faulty IoModule(s) on that SP.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specify an UnitySession Object.
      .PARAMETER Async
      Specifies if you want to run this command asynchronously.
      .PARAMETER dataCollection
      Collect information about the storage system and save it to a file.
      .PARAMETER dataCollectionProfile
      The profile used to collect service information.
      .PARAMETER includePrivateData
      Indicates whether the capture includes private data when performing the Save Configuration (configCapture) service action.
      .PARAMETER configCapture
      Save details about the configuration settings on the storage system to a file.
      .PARAMETER restartMGT
      Restart the management software to resolve connection problems between the system and Unisphere.
      .PARAMETER generateECOMDump
      Indicate whether generatate ECOM dump when restarting MGMT software. 
      .PARAMETER reinitialize
      Reset the storage system to the original factory settings. Both SPs must be installed and operating normally be in Service Mode.
      .PARAMETER changeServicePassword
      Change the service password for accessing the Service System page.
      .PARAMETER currentPassword
      Current password of the service user. needed when performing the Change Service Password (changeServicePassword) service action.
      .PARAMETER newPassword
      New password for the service user. Required for Change Service Password (changeServicePassword) action.
      .PARAMETER shutdownSystem
      The system shut down and power cycle procedures will attempt to resolve problems with your storage system that could not be resolved by rebooting or reimaging the SP. 
      .PARAMETER changeSSHStatus
      Disable the Secure Shell (SSH) protocol to block SSH access to the system, or enable the Secure Shell (SSH) protocol to enable access to the system. 
      .PARAMETER enterServiceModeSPA
      Stop I/O on the SP A so that the SP can enter service mode safely.
      .PARAMETER enterServiceModeSPB
      Stop I/O on the SP B so that the SP can enter service mode safely.
      .PARAMETER rebootSPA
      Reboot the selected SP.
      .PARAMETER rebootSPB
      Reboot the selected SP.
      .PARAMETER reimageSPB
      Reimage the selected SP.
      .PARAMETER reimageSPB
      Reimage the selected SP.
      .PARAMETER resetAndHoldSPA
      Reset and hold the selected SP.
      .PARAMETER resetAndHoldSPB
      Reset and hold the selected SP.
      .EXAMPLE
      Set-UnityserviceAction -changeSSHStatus

      Change the SSH status depending of the current state 
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High',DefaultParameterSetName="changeSSHStatus")]
  Param (
    #Default Parameters
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    [Switch]$Async,

    #dataCollection
    [Parameter(Mandatory = $true,ParameterSetName="dataCollection",HelpMessage = 'Collect information about the storage system and save it to a file.')]
    [Switch]$dataCollection,
    [Parameter(Mandatory = $false,ParameterSetName="dataCollection",HelpMessage = 'Indicates whether the capture includes private data when performing the Save Configuration (configCapture) service action.')]
    [Switch]$includePrivateData,
    [Parameter(Mandatory = $false,ParameterSetName="dataCollection",HelpMessage = 'The profile used to collect service information.')]
    [DataCollectionProfileEnum]$dataCollectionProfile,
    
    #changeSSHStatus
    [Parameter(Mandatory = $true,ParameterSetName="changeSSHStatus",HelpMessage = 'Disable or enable SSH')]
    [Switch]$changeSSHStatus,
    [Parameter(Mandatory = $true,ParameterSetName="changeSSHStatus",HelpMessage = 'Current Service password')]
    [String]$currentPassword
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand.Name)] Executing function"
    Write-Debug -Message "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
    Write-Debug -Message "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand.Name)] Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If ($Sess.TestConnection()) {

        $ID = $PsCmdlet.ParameterSetName

        #Building the URI
        $URI = 'https://'+$sess.Server+'/api/instances/serviceAction/'+$ID+'/action/execute'
        

        If ($PSBoundParameters.ContainsKey('Async')) {
          $URI = $URI + "?timeout=0" #run async
        }

        Write-Debug -Message "[$($MyInvocation.MyCommand.Name)] URI: $URI"

        #Building request body
        If ($pscmdlet.ShouldProcess($ID,"Service Action")) {
          Switch ($ID) {
            'dataCollection' {

              $body = @{}

              If ($PSBoundParameters.ContainsKey('includePrivateData')) {
                $body['includePrivateData'] = $True
              }

              If ($PSBoundParameters.ContainsKey('dataCollectionProfile')) {
                $body['dataCollectionProfile'] = $dataCollectionProfile
              }

              $request = Send-UnityRequest -uri $URI -Session $Sess -Method 'POST' -Body $Body 

            }
            'changeSSHStatus' {
              $body = @{}
              $body['currentPassword'] = $currentPassword

              $request = Send-UnityRequest -uri $URI -Session $Sess -Method 'POST' -Body $Body
            }
            default {}
          }
        }

        Write-Debug -Message "[$($MyInvocation.MyCommand.Name)] Request status code: $($request.StatusCode)"

        If (($request.StatusCode -eq '200') -or ($request.StatusCode -eq '204')) {

          If ($ID -eq 'dataCollection') {

            # Return the last data collection result object available. This ugly woraround is needed because the request does not send back the id of the created data collection. 
            Get-UnityDataCollectionResult -Session $Sess | Sort-Object -Property CreationTime | Select-Object -Last 1

          } else {
            #Output result
            Get-UnityServiceAction -Session $Sess -ID $ID
          }
        } # End If (($request.StatusCode -eq '200') -or ($request.StatusCode -eq '204'))

        If ($request.StatusCode -eq '202'){
          #Output result
          $request.Content | ConvertFrom-Json
        }
      } # End Switch ($PsCmdlet.ParameterSetName)
    } # End Foreach ($sess in $session) {
  } # End Process

  End {}
}

Function Get-UnityserviceAction {

  <#
      .SYNOPSIS
      Information about storage system service actions. <br/> <br/> Collect Service Information (dataCollection): Collect information about the storage system and save it to a file. Your service provider can use the collected information to analyze the storage system. <br/> <br/> Save Configuration (configCapture): Save details about the configuration settings on the storage system to a file. Your service provider can use this file to assist you with reconfiguring your system after a major system failure or a system reinitialization. <br/> <br/> Restart Management Software (restartMGT): Restart the management software to resolve connection problems between the system and Unisphere. <br/> <br/> Reinitialize (reinitialize): Reset the storage system to the original factory settings. Both SPs must be installed and operating normally be in Service Mode. <br/> <br/> Change Service Password (changeServicePassword): Change the service password for accessing the Service System page. <br/> <br/> Shut Down System (shutdownSystem): The system shut down and power cycle procedures will attempt to resolve problems with your storage system that could not be resolved by rebooting or reimaging the SP. <br/> <br/> Disable SSH/Enable SSH (changeSSHStatus): Disable the Secure Shell (SSH) protocol to block SSH access to the system, or enable the Secure Shell (SSH) protocol to enable access to the system. <br/> <br/> Enter Service Mode (enterServiceModeSPA, enterServiceModeSPB): Stop I/O on the SP so that the SP can enter service mode safely. <br/> <br/> Reboot (rebootSPA, rebootSPB): Reboot the selected SP. Use this service action to attempt to resolve minor problems related to system software or SP hardware components. <br/> <br/> Reimage (rebootSPA, rebootSPB): Reimage the selected SP. Reimaging analyzes the system software on the SP and attempts to correct any problems automatically. <br/> <br/> Reset and Hold(resetAndHoldSPA, resetAndHoldSPB): Reset and hold the selected SP. Use this service task to attempt to reset and hold the SP, so that users can replace the faulty IoModule(s) on that SP. <br/> <br/>  
      .DESCRIPTION
      Information about storage system service actions. <br/> <br/> Collect Service Information (dataCollection): Collect information about the storage system and save it to a file. Your service provider can use the collected information to analyze the storage system. <br/> <br/> Save Configuration (configCapture): Save details about the configuration settings on the storage system to a file. Your service provider can use this file to assist you with reconfiguring your system after a major system failure or a system reinitialization. <br/> <br/> Restart Management Software (restartMGT): Restart the management software to resolve connection problems between the system and Unisphere. <br/> <br/> Reinitialize (reinitialize): Reset the storage system to the original factory settings. Both SPs must be installed and operating normally be in Service Mode. <br/> <br/> Change Service Password (changeServicePassword): Change the service password for accessing the Service System page. <br/> <br/> Shut Down System (shutdownSystem): The system shut down and power cycle procedures will attempt to resolve problems with your storage system that could not be resolved by rebooting or reimaging the SP. <br/> <br/> Disable SSH/Enable SSH (changeSSHStatus): Disable the Secure Shell (SSH) protocol to block SSH access to the system, or enable the Secure Shell (SSH) protocol to enable access to the system. <br/> <br/> Enter Service Mode (enterServiceModeSPA, enterServiceModeSPB): Stop I/O on the SP so that the SP can enter service mode safely. <br/> <br/> Reboot (rebootSPA, rebootSPB): Reboot the selected SP. Use this service action to attempt to resolve minor problems related to system software or SP hardware components. <br/> <br/> Reimage (rebootSPA, rebootSPB): Reimage the selected SP. Reimaging analyzes the system software on the SP and attempts to correct any problems automatically. <br/> <br/> Reset and Hold(resetAndHoldSPA, resetAndHoldSPB): Reset and hold the selected SP. Use this service task to attempt to reset and hold the SP, so that users can replace the faulty IoModule(s) on that SP. <br/> <br/>  
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
      Get-UnityserviceAction

      Retrieve information about all UnityserviceAction
      .EXAMPLE
      Get-UnityserviceAction -ID 'id01'

      Retrieves information about a specific UnityserviceAction
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='Name',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnityserviceAction Name')]
    [String[]]$Name,
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnityserviceAction ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/serviceAction/instances' #URI
    $TypeName = 'UnityserviceAction'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


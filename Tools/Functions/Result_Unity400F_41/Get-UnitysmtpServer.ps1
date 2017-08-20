Function Get-UnitysmtpServer {

  <#
      .SYNOPSIS
      Information about the SMTP servers in the storage system. You can define up to two SMTP servers: <br/> <br/> <ul> <li> The default SMTP server sends email alerts to the IP addresses specified in the AlertConfigSNMPTarget resource when it encounters alert or error conditions. </li> <br/> <br/> <li>The ConnectEMC SMTP server sends the same alerts to the dial-home addresses specified in the AlertConfigSNMPTarget resource. It also sends additional information, if any, to EMC Support.</li> <li>If EMC Secure Remote Support (ESRS) is configured, the system uses that mechanism instead of the ConnectEMC SMTP server to send alert information.</li> </ul>  
      .DESCRIPTION
      Information about the SMTP servers in the storage system. You can define up to two SMTP servers: <br/> <br/> <ul> <li> The default SMTP server sends email alerts to the IP addresses specified in the AlertConfigSNMPTarget resource when it encounters alert or error conditions. </li> <br/> <br/> <li>The ConnectEMC SMTP server sends the same alerts to the dial-home addresses specified in the AlertConfigSNMPTarget resource. It also sends additional information, if any, to EMC Support.</li> <li>If EMC Secure Remote Support (ESRS) is configured, the system uses that mechanism instead of the ConnectEMC SMTP server to send alert information.</li> </ul>  
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
      Get-UnitysmtpServer

      Retrieve information about all UnitysmtpServer
      .EXAMPLE
      Get-UnitysmtpServer -ID 'id01'

      Retrieves information about a specific UnitysmtpServer
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnitysmtpServer ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/smtpServer/instances' #URI
    $TypeName = 'UnitysmtpServer'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


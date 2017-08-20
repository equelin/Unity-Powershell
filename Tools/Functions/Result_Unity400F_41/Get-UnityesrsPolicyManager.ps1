Function Get-UnityesrsPolicyManager {

  <#
      .SYNOPSIS
      Information about the EMC Remote Support (ESRS) policy manager configuration<br/> <br/> The storage system Remote Support is enabled with the EMC&#8217;s leading remote support platform: EMC Secure Remote Support (ESRS). ESRS is a remote monitoring and support feature that provides authorized EMC remote access capabilities to the storage systems via a secure and encrypted tunnel. The secure tunnel that ESRS establishes between the storage system and systems on the EMC network can be used to transfer files out to the storage system or back to EMC.<br/> <br/> ESRS policy manager is run on a dedicated server which allows customers to control remote sessions and define customized ESRS policy. <br/> <b>Examples</b> <br/> <br/> <html> <head> <style> div.examplebox { background-color: #eff5fa; width: 600px; padding: 5px; border: 2px solid black; } </style> </head> <body> <br/> <br/> <b>Checking the ESRS policy manager setting</b><br/> <br/> <div class="examplebox"> <p> GET /api/types/esrsPolicyManager/instances?fields=id,isEnabled,address,useHTTPS,sslStrength,proxyIsEnabled,proxyAddress,proxyUseSocks,proxyUserName<br/> <br/> Sample response:<br/> <br/> &quot;content&quot;:<br/> { <br/> &nbsp;&nbsp;&nbsp;&nbsp;&quot;isEnabled&quot; : &quot;true&quot;<br/> &nbsp;&nbsp;&nbsp;&nbsp;&quot;address&quot; : &quot;10.244.237.79:9443&quot;<br/> &nbsp;&nbsp;&nbsp;&nbsp;&quot;useHTTPS&quot; : &quot;true&quot;<br/> &nbsp;&nbsp;&nbsp;&nbsp;&quot;sslStrength&quot; : &quot;2&quot;<br/> &nbsp;&nbsp;&nbsp;&nbsp;&quot;proxyIsEnabled&quot; : &quot;false&quot;<br/> &nbsp;&nbsp;&nbsp;&nbsp;&quot;proxyUseSocks&quot; : &quot;true&quot;<br/> }<br/> <br/> </p> </div> <br/> <br/> <b>Configuring ESRS VE with a Policy Manager</b><br/> <br/> This example uses the default port and default protocol (socks, secure)<br/> <br/> <div class="examplebox"> <p> POST /api/instances/esrsPolicyManager/0/action/modify <br/> { <br/> &nbsp;&nbsp;&nbsp;&nbsp;&quot;isEnabled&quot; : &quot;true&quot;,<br/> &nbsp;&nbsp;&nbsp;&nbsp;&quot;address&quot; : &quot;10.105.221.123&quot;,<br/> }<br/> </p> </div> <br/> <br/> </p> </div> </body> </html>  
      .DESCRIPTION
      Information about the EMC Remote Support (ESRS) policy manager configuration<br/> <br/> The storage system Remote Support is enabled with the EMC&#8217;s leading remote support platform: EMC Secure Remote Support (ESRS). ESRS is a remote monitoring and support feature that provides authorized EMC remote access capabilities to the storage systems via a secure and encrypted tunnel. The secure tunnel that ESRS establishes between the storage system and systems on the EMC network can be used to transfer files out to the storage system or back to EMC.<br/> <br/> ESRS policy manager is run on a dedicated server which allows customers to control remote sessions and define customized ESRS policy. <br/> <b>Examples</b> <br/> <br/> <html> <head> <style> div.examplebox { background-color: #eff5fa; width: 600px; padding: 5px; border: 2px solid black; } </style> </head> <body> <br/> <br/> <b>Checking the ESRS policy manager setting</b><br/> <br/> <div class="examplebox"> <p> GET /api/types/esrsPolicyManager/instances?fields=id,isEnabled,address,useHTTPS,sslStrength,proxyIsEnabled,proxyAddress,proxyUseSocks,proxyUserName<br/> <br/> Sample response:<br/> <br/> &quot;content&quot;:<br/> { <br/> &nbsp;&nbsp;&nbsp;&nbsp;&quot;isEnabled&quot; : &quot;true&quot;<br/> &nbsp;&nbsp;&nbsp;&nbsp;&quot;address&quot; : &quot;10.244.237.79:9443&quot;<br/> &nbsp;&nbsp;&nbsp;&nbsp;&quot;useHTTPS&quot; : &quot;true&quot;<br/> &nbsp;&nbsp;&nbsp;&nbsp;&quot;sslStrength&quot; : &quot;2&quot;<br/> &nbsp;&nbsp;&nbsp;&nbsp;&quot;proxyIsEnabled&quot; : &quot;false&quot;<br/> &nbsp;&nbsp;&nbsp;&nbsp;&quot;proxyUseSocks&quot; : &quot;true&quot;<br/> }<br/> <br/> </p> </div> <br/> <br/> <b>Configuring ESRS VE with a Policy Manager</b><br/> <br/> This example uses the default port and default protocol (socks, secure)<br/> <br/> <div class="examplebox"> <p> POST /api/instances/esrsPolicyManager/0/action/modify <br/> { <br/> &nbsp;&nbsp;&nbsp;&nbsp;&quot;isEnabled&quot; : &quot;true&quot;,<br/> &nbsp;&nbsp;&nbsp;&nbsp;&quot;address&quot; : &quot;10.105.221.123&quot;,<br/> }<br/> </p> </div> <br/> <br/> </p> </div> </body> </html>  
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
      Get-UnityesrsPolicyManager

      Retrieve information about all UnityesrsPolicyManager
      .EXAMPLE
      Get-UnityesrsPolicyManager -ID 'id01'

      Retrieves information about a specific UnityesrsPolicyManager
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='Name',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnityesrsPolicyManager Name')]
    [String[]]$Name,
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnityesrsPolicyManager ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/esrsPolicyManager/instances' #URI
    $TypeName = 'UnityesrsPolicyManager'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


Function Disconnect-Unity {

  <#
      .SYNOPSIS
      Disconnects from an EMC Unity Array
      .DESCRIPTION
      Disconnects from an EMC Unity Array. By default, Disconnect-Unity closes all sessions. To close a specific session, use the -Session parameter.
      When a session is disconnected, it is removed form the default array list.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specifies an UnitySession Object.
      .EXAMPLE
      Disconnect-Unity

      Disconnects all the sessions
      .EXAMPLE
      $Session = Get-UnitySession -Server 192.168.0.1
      Disconnect-Unity -Session $Session

      Disconnects all the sessions matching the IP of the array 192.168.0.1

  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    [Parameter(Mandatory = $false,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'EMC Unity Session')]
    $session = $global:DefaultUnitySession
  )
  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"
  }

  Process {
    Foreach ($sess in $session) {

      Write-Verbose "Processing session with array: $($sess.Server) and SessionID: $($sess.SessionID) "

      If ($Sess.IsConnected -eq $false) {

        Write-Verbose "Session already disconnected. Delete it from DefaultUnitySession"
        $global:DefaultUnitySession = $global:DefaultUnitySession | where-object {$_.SessionId -notmatch $Sess.SessionId}

      } else {

        #Building URI
        $uri = 'https://'+$sess.Server+'/api/types/loginSessionInfo/action/logout'

        Write-Verbose "URI: $URI"

        Write-Verbose "Disconnecting session $($sess.SessionID)"

        if ($pscmdlet.ShouldProcess($sess.Server,"Disconnecting from Unity Array")) {

          #Sending request
          $request = Invoke-WebRequest -Uri $URI -ContentType "application/json" -Websession $sess.Websession -Headers $sess.headers -Method POST

          If ($request.StatusCode -eq 200) {
            Write-Verbose "Delete session from DefaultUnitySession"
            $global:DefaultUnitySession = $global:DefaultUnitySession | where-object {$_.SessionId -notmatch $Sess.SessionId}
          }
        }
      }
    }
  }

  End {
    ## update the Windows PowerShell titlebar with a bit of info about the Unity array(s) to which the PowerShell session is connected
    Update-TitleBarForUnityConnection
  }
}

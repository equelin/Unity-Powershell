Function Test-UnityConnection {
  [CmdletBinding()]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    [Array]$session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true})
  )
  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"
  }

  Process {
    Foreach ($Sess in $session) {

      Write-Verbose "Processing Array: $($sess.Server)"

      $URI = 'https://'+$sess.Server+'/api/types/system/instances'

      Write-Verbose "URI: $URI"

      Try {
        $request = Invoke-WebRequest -Uri $URI -ContentType "application/json" -Websession $sess.Websession -Headers $sess.headers -Method 'GET' -UseBasicParsing
      }

      Catch {
        $global:DefaultUnitySession |
          where-object {$_.SessionId -eq $sess.SessionId} |
            foreach {
              $currentObject = $_
              $currentObject.IsConnected = $false
              $currentObject
            } | Out-Null
        Return $false
      }
    }
    Return $True
  }
  End {}
}

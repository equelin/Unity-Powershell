Function Disable-UnityFastCache {

  <#
      .SYNOPSIS
      Disable FAST Cache.
      .DESCRIPTION
      Disable FAST Cache.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specifies an UnitySession Object.
      .EXAMPLE
      Disable-UnityFastCache

      Disable FAST Cache.
  #>

    [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    #Default Parameters
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true})
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"
  }

  Process {

    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If ($Sess.TestConnection()) {

          #Building the URI
          $URI = 'https://'+$sess.Server+'/api/instances/fastCache/0/action/disable?timeout=0' #run async
          Write-Verbose "URI: $URI"

          #Sending the request
          If ($pscmdlet.ShouldProcess($($Sess.Server),"Disable Fast Cache")) {
            $request = Send-UnityRequest -uri $URI -Session $Sess -Method 'POST' -Body $Body
          }

          If ($request.StatusCode -eq '202') {
            Write-Host "Fast Cache is currently disabling"
          }
      }
    }
  }
}

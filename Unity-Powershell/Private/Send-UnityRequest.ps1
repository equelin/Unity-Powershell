function Send-UnityRequest {
  [CmdletBinding()]
  Param (
      [parameter(Mandatory = $true, HelpMessage = "Request URI")]
      [string]$URI,
      [Parameter(Mandatory = $true,HelpMessage = 'EMC Unity Session')]
      $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
      [parameter(Mandatory = $true, HelpMessage = "Enter request type (GET POST DELETE)")]
      [string]$Method,
      [parameter(Mandatory = $false, HelpMessage = "Body of the message")]
      [array]$body
  )

  Write-Verbose "Executing function: $($MyInvocation.MyCommand)"

  # Request
  If (($Method -eq 'GET') -or ($type -eq 'DELETE')) {
    Try
    {
      $data = Invoke-WebRequest -Uri $URI -ContentType "application/json" -Websession $Session.Websession -Headers $session.headers -Method $Method
      return $data
    }
    Catch
    {
      Show-RequestException -Exception $_
      throw
    }
  }
  If (($Method -eq 'POST') -or ($type -eq 'PUT')) {
    Try
    {
      $json = $body | ConvertTo-Json -Depth 3
      $data = Invoke-WebRequest -Uri $URI -ContentType "application/json" -Body $json -Websession $Session.Websession -Headers $session.headers -Method $Method -TimeoutSec 600
      return $data
    }
    Catch
    {
      Show-RequestException -Exception $_
      throw
    }
  }
  If ($Method -eq 'DELETE') {
    Try
    {
      If ($body) {
        $json = $body | ConvertTo-Json -Depth 3
        $data = Invoke-WebRequest -Uri $URI -ContentType "application/json" -Body $json -Websession $Session.Websession -Headers $session.headers -Method $Method
      } else {
        $data = Invoke-WebRequest -Uri $URI -ContentType "application/json" -Websession $Session.Websession -Headers $session.headers -Method $Method
      }
      return $data
    }
    Catch
    {
      Show-RequestException -Exception $_
      throw
    }
  }
}

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

    #Initialazing Websession variable
    $Websession = New-Object Microsoft.PowerShell.Commands.WebRequestSession

    #Add session's cookies to Websession
    Foreach ($cookie in $sess.Cookies) {
      Write-Verbose "Add cookie: $($cookie.Name) to WebSession"
      $Websession.Cookies.Add($cookie);
    }

    # Request
    If (($Method -eq 'GET') -or ($type -eq 'DELETE')) {
      Try
      {
          $data = Invoke-WebRequest -Uri $URI -ContentType "application/json" -Websession $Websession -Headers $session.headers -Method $Method
          return $data
      }
      Catch
      {
        throw
      }
    }
    If (($Method -eq 'POST') -or ($type -eq 'PUT')) {
      Try
      {
        $json = $body | ConvertTo-Json
        $data = Invoke-WebRequest -Uri $URI -ContentType "application/json" -Body $json -Websession $Websession -Headers $session.headers -Method $Method
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
        $data = Invoke-WebRequest -Uri $URI -ContentType "application/json" -Websession $Websession -Headers $session.headers -Method $Method
        return $data
      }
      Catch
      {
        throw
      }
    }

}

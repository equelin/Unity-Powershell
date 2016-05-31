Function Get-UnityAuth {
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory = $true,Position = 0,HelpMessage = 'EMC Unity FQDN or IP address',ParameterSetName='p1')]
    [ValidateNotNullorEmpty()]
    [String]$Server,
    [Parameter(Mandatory = $true,Position = 0,HelpMessage = 'EMC Unity Rest URI',ParameterSetName='p2')]
    [ValidateNotNullorEmpty()]
    [String]$URI,
    [Parameter(Mandatory = $true,Position = 1,HelpMessage = 'EMC Unity Encoded Password')]
    $EncodedPassword,
    [Parameter(Mandatory = $false,Position = 2,HelpMessage = 'EMC Unity Cookies')]
    [System.Net.CookieContainer]$Cookies
  )

  If ($PsCmdlet.ParameterSetName -eq 'p1') {
    Write-Verbose -Message 'Build the URI'
    $URI= 'https://'+$Server+'/api/types/system/instances'
  }

  Write-Verbose "URI: $URI"

  $Request = [System.Net.HttpWebRequest]::Create($URI)
  $Request.CookieContainer = $Cookies
  $Request.AllowAutoRedirect = $false
  $Request.Accept = "application/json"
  $Request.ContentType = "application/json"
  $Request.Headers.Add("X-EMC-REST-CLIENT","true")
  $Request.Headers.Add('Authorization',"Basic $($EncodedPassword)")

  Write-Verbose "Sending authentication request"

  Try {
    $NewResponse = $Request.GetResponse()
    $NewResponse.Close()
  }
  Catch {
    Show-RequestException -Exception $_
    throw
  }

  Write-Verbose "Processing cookies"
  Foreach ($cookie in $NewResponse.Cookies) {
    Write-Verbose "Adding cookie: $($cookie.Name)"
    $Cookies.Add($cookie)
  }

  Write-Verbose "Response Status Code: $($NewResponse.StatusCode)"

  If ($NewResponse.StatusCode -eq 'OK') {

    $headers = @{}
    $headers["Accept"] = "application/json"
    $headers["X-EMC-REST-CLIENT"] = "true"
    $headers["EMC-CSRF-TOKEN"] = $NewResponse.Headers.item('EMC-CSRF-TOKEN')

    $result = @{}
    $result['Headers'] = $headers
    $result['Cookies'] = $Cookies.GetCookies($uri)

    return $result

  } else {
    Get-UnityAuth -URI $NewResponse.Headers.item('Location') -EncodedPassword $EncodedPassword -Cookies $Cookies
  }
}

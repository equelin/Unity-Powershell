Function Show-RequestException {
  [CmdletBinding()]
  Param(
    [parameter(Mandatory = $true)]
    $Exception
  )

  Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

  #Exception catch when there's a connectivity problem with the array
  If ($Exception.Exception.InnerException) {
    Write-Host "Please verify the connectivity with the array" -foreground yellow
    Write-Host
    Write-Host "Error details: $($Exception.Exception.InnerException.Message)" -foreground yellow
    Write-Host
  }

  #Exception catch when the rest request return an error
  If ($Exception.Exception.Response) {

    $result = $Exception.Exception.Response.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($result)
    $responseBody = $reader.ReadToEnd()
    $JSON =  $responseBody | ConvertFrom-Json

    Write-Host "The array sends an error message:" -foreground yellow
    Write-Host
    Write-Host "Error code: $($Exception.Exception.Response.StatusCode)" -foreground yellow
    Write-Host "Error description: $($Exception.Exception.Response.StatusDescription)" -foreground yellow
    Write-Host "Error details: $responseBody" -foreground yellow
    Write-Host
  }
}

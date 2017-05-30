Function Set-UnityDNSServer {

  <#
      .SYNOPSIS
      Modifies DNS Servers parameters.
      .DESCRIPTION
      Modifies DNS Servers parameters.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specify an UnitySession Object.
      .PARAMETER addresses
      New list of IP addresses to replace the exsting address list for this DNS server.
      .EXAMPLE
      Set-UnityDnsServer -Addresses '192.0.2.1','192.0.2.2'

      replace the exsting address list for this DNS server with this new list.
  #>

    [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'New list of IP addresses to replace the exsting address list for this DNS server.')]
    [String[]]$Addresses
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    # Variables
    $URI = '/api/instances/dnsServer/<id>/action/modify'
    $Type = 'DNS Server'
    $StatusCode = 204
  }

  Process {

    Foreach ($sess in $session) {

      Write-Debug -Message "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If ($Sess.TestConnection()) {

          $Object = Get-UnityDnsServer -Session $Sess

          $ObjectID = $Object.id

          #### REQUEST BODY 

          # Creation of the body hash
          $body = @{}
          $body['addresses'] = @()

          Foreach ($Addresse in $Addresses) {
            $body["addresses"] += $Addresse
          }

          ####### END BODY - Do not edit beyond this line

          #Show $body in verbose message
          $Json = $body | ConvertTo-Json -Depth 10
          Write-Verbose $Json 

          #Building the URL
          $FinalURI = $URI -replace '<id>',$ObjectID

          $URL = 'https://'+$sess.Server+$FinalURI
          Write-Verbose "URL: $URL"

          #Sending the request
          If ($pscmdlet.ShouldProcess($Sess.Name,"Modify $Type $ObjectID")) {
            $request = Send-UnityRequest -uri $URL -Session $Sess -Method 'POST' -Body $Body
          }

          If ($request.StatusCode -eq $StatusCode) {

            Write-Verbose "$Type with ID $ObjectID has been modified"

            Get-UnityDnsServer -Session $Sess
          }

      } else {
        Write-Information -MessageData "You are no longer connected to EMC Unity array: $($Sess.Server)"
      }
    }
  }

  End {}
}

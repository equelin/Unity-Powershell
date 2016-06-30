Function New-UnityFileDNSServer {

  <#
      .SYNOPSIS
      Creates a DNS file server.
      .DESCRIPTION
      Creates a DNS file server.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under Apache licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .EXAMPLE
      New-UnityFileDNSServer -nasServer 'nas_1' -domain 'example.com' -ip '192.168.0.1','192.168.0.2'

      Create a DNS file server associated to NAS server 'nas_1'
  #>

  [CmdletBinding()]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $true,Position = 1,HelpMessage = 'ID of the NAS server to which the network interface belongs')]
    $nasServer,
    [Parameter(Mandatory = $true,HelpMessage = 'DNS domain name')]
    [string]$domain,
    [Parameter(Mandatory = $true,HelpMessage = 'Prioritized list of one to three IPv4 and/or IPv6 addresses of DNS servers for the domain')]
    [String[]]$addresses
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"

    #Initialazing arrays
    $ResultCollection = @()
  }

  Process {
    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      # Creation of the body hash
      $body = @{}

      # nasServer argument
      $body["nasServer"] = @{}
      $nasServerArg = @{}
      $nasServerArg["id"] = "$($nasServer)"
      $body["nasServer"] = $nasServerArg

      #Addresses argument
      $body['addresses'] = @()
      Foreach ($Addresse in $Addresses) {
        $body["addresses"] += $Addresse
      }

      If ($PSBoundParameters.ContainsKey('domain')) {
            $body["domain"] = "$($domain)"
      }

      If (Test-UnityConnection -Session $Sess) {

        #Building the URI
        $URI = 'https://'+$sess.Server+'/api/types/fileDNSServer/instances'
        Write-Verbose "URI: $URI"

        #Sending the request
        $request = Send-UnityRequest -uri $URI -Session $Sess -Method 'POST' -Body $Body

        Write-Verbose "Request status code: $($request.StatusCode)"

        If ($request.StatusCode -eq '201') {

          #Formating the result. Converting it from JSON to a Powershell object
          $results = ($request.content | ConvertFrom-Json).content

          Write-Verbose "File interface created with the ID: $($results.id) "

          #Executing Get-UnityUser with the ID of the new user
          Get-UnityFileDNSServer -Session $Sess -ID $results.id
        }
      } else {
        Write-Information -MessageData "You are no longer connected to EMC Unity array: $($Sess.Server)"
      }

    }
  }

  End {}
}

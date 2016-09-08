Function New-UnityFileDNSServer {

  <#
      .SYNOPSIS
      Create a new DNS server for a NAS Server.
      .DESCRIPTION
      Create a new DNS server for a NAS Server.
      Only one instance can be created per NAS server.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specify an UnitySession Object.
      .PARAMETER nasServer
      ID of the NAS server to which the DNS server belongs.
      .PARAMETER domain
      DNS domain name
      .PARAMETER addresses
      Prioritized list of one to three IPv4 and/or IPv6 addresses of DNS server(s) for the domain
      .PARAMETER Confirm
      If the value is $true, indicates that the cmdlet asks for confirmation before running. If the value is $false, the cmdlet runs without asking for user confirmation.
      .PARAMETER WhatIf
      Indicate that the cmdlet is run only to display the changes that would be made and actually no objects are modified.
      .EXAMPLE
      New-UnityFileDNSServer -nasServer 'nas_1' -domain 'example.com' -ip '192.168.0.1','192.168.0.2'

      Create a DNS file server associated to NAS server 'nas_1'
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $true,Position = 1,HelpMessage = 'ID of the NAS server to which the DNS server belongs')]
    $nasServer,
    [Parameter(Mandatory = $true,HelpMessage = 'DNS domain name')]
    [string]$domain,
    [Parameter(Mandatory = $true,HelpMessage = 'Prioritized list of one to three IPv4 and/or IPv6 addresses of DNS servers for the domain')]
    [String[]]$addresses
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"

    ## Variables
    $URI = '/api/types/fileDNSServer/instances'
    $Type = 'File DNS Server'
    $StatusCode = 201
  }

  Process {
    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      #### REQUEST BODY 

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

      ####### END BODY - Do not edit beyond this line

      #Show $body in verbose message
      $Json = $body | ConvertTo-Json -Depth 10
      Write-Verbose $Json  

      If ($Sess.TestConnection()) {

        ##Building the URL
        $URL = 'https://'+$sess.Server+$URI
        Write-Verbose "URL: $URL"

        #Sending the request
        If ($pscmdlet.ShouldProcess($Sess.Name,"Create $Type $domain")) {
          $request = Send-UnityRequest -uri $URL -Session $Sess -Method 'POST' -Body $Body
        }

        Write-Verbose "Request status code: $($request.StatusCode)"

        If ($request.StatusCode -eq $StatusCode) {

          #Formating the result. Converting it from JSON to a Powershell object
          $results = ($request.content | ConvertFrom-Json).content

          Write-Verbose "$Type with the ID $($results.id) has been created"

          #Executing Get-UnityUser with the ID of the new user
          Get-UnityFileDNSServer -Session $Sess -ID $results.id
        } # End If ($request.StatusCode -eq $StatusCode)
      } # End If ($Sess.TestConnection())
    } # End Foreach ($sess in $session)
  } # End Process
} # End Function

Function Get-UnityItem {

  <#
      .SYNOPSIS
      Queries the EMC Unity array to retrieve informations about a specific item.
      .DESCRIPTION
      Querries the EMC Unity array to retrieve informations about a specific item. You need to provide the URI of the item (ex: /api/types/pool/instances)  with the parameter -URI.
      By default, the response is a powershell object. You can retrieve the JSON response by using the -JSON parameter.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under Apache licence
      .LINK
      https://github.com/equelin/Unity-Powershell
      .EXAMPLE
      Get-UnityItem -URI '/api/types/pool/instances'

      Retrieve information about pools.  Return a powershell object
      .EXAMPLE
      Get-UnityItem -URI '/api/types/pool/instances' -JSON

      Retrieves information about pools. Return data in the JSON format
  #>

  [CmdletBinding()]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $true,HelpMessage = 'EMC Unity Session')]
    [String]$URI,
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    [Switch]$JSON
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"

    #Initialazing arrays
    $ResultCollection = @()

    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If (Test-UnityConnection -Session $Sess) {

        #Building the URI
        $URL = 'https://'+$sess.Server+$URI
        Write-Verbose "URI: $URL"

        #Sending the request
        $request = Send-UnityRequest -uri $URL -Session $Sess -Method 'GET'


        #Formating the result. Converting it from JSON to a Powershell object
        If ($JSON) {
          $results = $request.content
        } else {
          $results = $request.content | ConvertFrom-Json
        }

        Write-Output $results

      } else {
        Write-Host "You are no longer connected to EMC Unity array: $($Sess.Server)"
      }
    }
  }

  Process {}

  End {}
}

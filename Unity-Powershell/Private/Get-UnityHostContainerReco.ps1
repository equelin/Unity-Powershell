Function Get-UnityHostContainerReco {

  <#
      .SYNOPSIS
      Get the hostContainer recommendations for importing ESXi servers
      .NOTES
      Written by Erwan Quelin under Apache licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
  #>

  [CmdletBinding()]
  Param (
    #Default Parameters
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),

    #vCenter
    [Parameter(Mandatory = $true,Position = 1,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'The IP address of the vCenter server')]
    [String[]]$Address,
    [Parameter(Mandatory = $true,HelpMessage = 'The user name to access vCenter server')]
    [string]$Username,
    [Parameter(Mandatory = $true,HelpMessage = 'The password to connect to vCenter server')]
    [String]$Password
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"

    #Initialazing arrays
    $ResultCollection = @()
  }

  Process {
    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      Foreach ($a in $Address) {

        # Creation of the body hash
        $body = @{}

        # address parameter
        $body["address"] = "$a"

        # username parameter
        $body["username"] = "$Username"

        # password parameter
        $body["password"] = "$Password"

        If (Test-UnityConnection -Session $Sess) {

          #Building the URI
          $URI = 'https://'+$sess.Server+'/api/types/hostContainer/action/recommend'
          Write-Verbose "URI: $URI"

          #Sending the request
          $request = Send-UnityRequest -uri $URI -Session $Sess -Method 'POST' -Body $Body

          Write-Verbose "Request status code: $($request.StatusCode)"

          If ($request.StatusCode -eq '200') {

            #Formating the result
            $results = ($request.content | ConvertFrom-Json).content

            Write-Output $results
            
          }
        } else {
          Write-Warning "You are no longer connected to EMC Unity array: $($Sess.Server)"
        }
      }
    }
  }

  End {}
}

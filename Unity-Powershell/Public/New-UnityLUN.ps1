Function New-UnityLUN {
  [CmdletBinding()]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'LUN Name')]
    [String[]]$Name,
    [Parameter(Mandatory = $false,HelpMessage = 'LUN Description')]
    [String]$Description,
    [Parameter(Mandatory = $true,HelpMessage = 'LUN Pool ID')]
    [String]$Pool,
    [Parameter(Mandatory = $true,HelpMessage = 'LUN Size in Bytes')]
    [String]$Size,
    [Parameter(Mandatory = $false,HelpMessage = 'Is Thin enabled on LUN ? (Default is true)')]
    [String]$isThinEnabled = $true
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"

    #Initialazing arrays
    $ResultCollection = @()
  }

  Process {
    Foreach ($n in $Name) {

      # Creation of the body hash
      $body = @{}

      # Name parameter
      $body["name"] = "$($n)"

      # Domain parameter
      If ($Description) {
            $body["description"] = "$($Description)"
      }

      # lunParameters parameter
      $body["lunParameters"] = @{}
      $lunParameters = @{}
      $poolParameters = @{}
      $poolParameters["id"] = "$($Pool)"
      $lunParameters["pool"] = $poolParameters
      $lunParameters["size"] = $($Size)

      # isThinEnabled
      If ($isThinEnabled) {
        $lunParameters["isThinEnabled"] = $isThinEnabled
      }

      $body["lunParameters"] = $lunParameters

      Foreach ($sess in $session) {

        Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

        If (Test-UnityConnection -Session $Sess) {

          #Building the URI
          $URI = 'https://'+$sess.Server+'/api/types/storageResource/action/createLun'
          Write-Verbose "URI: $URI"

          #Sending the request
          $request = Send-UnityRequest -uri $URI -Session $Sess -Method 'POST' -Body $Body

          Write-Verbose "Request status code: $($request.StatusCode)"

          If ($request.StatusCode -eq '200') {

            #Formating the result. Converting it from JSON to a Powershell object
            $results = ($request.content | ConvertFrom-Json).content.storageResource

            Write-Verbose "LUN created with the ID: $($results.id) "

            #Executing Get-UnityUser with the ID of the new user
            Get-UnityLUN -ID $results.id
          }
        } else {
          Write-Host "You are no longer connected to EMC Unity array: $($Sess.Server)"
        }
      }
    }
  }

  End {
  }
}

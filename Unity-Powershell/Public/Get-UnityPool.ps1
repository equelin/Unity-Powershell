Function Get-UnityPool {
  [CmdletBinding(DefaultParameterSetName="ByName")]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName="ByName",ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'LUN Name')]
    [String[]]$Name='*',
    [Parameter(Mandatory = $false,ParameterSetName="ByID",ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'LUN ID')]
    [String[]]$ID='*'
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"

    #Initialazing arrays
    $ResultCollection = @()

    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If (Test-UnityConnection -Session $Sess) {

        #Initialazing Websession variable
        $Websession = New-Object Microsoft.PowerShell.Commands.WebRequestSession

        #Add session's cookies to Websession
        Foreach ($cookie in $sess.Cookies) {
          Write-Verbose "Ajout cookie: $($cookie.Name)"
          $Websession.Cookies.Add($cookie);
        }

        #Building the URI
        $URI = 'https://'+$sess.Server+'/api/types/pool/instances?compact=true&fields=id,health,name'
        Write-Verbose "URI: $URI"

        #Sending the request
        $request = Send-UnityRequest -uri $URI -Session $Sess -Method 'GET'

        #Formating the result. Converting it from JSON to a Powershell object
        $results = ($request.content | ConvertFrom-Json).entries.content

        #Building the result collection (Add type)
        $ResultCollection += Add-UnityObjectType -Data $results -TypeName 'UnityPool'

      } else {
        Write-Host "You are no longer connected to EMC Unity array: $($Sess.Server)"
      }
    }
  }

  Process {
    #Filter results
    If ($ResultCollection) {
      Switch ($PsCmdlet.ParameterSetName) {
        'ByName' {
          Foreach ($N in $Name) {
            Write-Verbose "Return result(s) with the filter: $($N)"
            $ResultCollectionFiltered += $ResultCollection | Where-Object {$_.Name -like $N}
          }
        }
        'ByID' {
          Foreach ($I in $ID) {
            Write-Verbose "Return result(s) with the filter: $($I)"
            $ResultCollectionFiltered += $ResultCollection | Where-Object {$_.Id -like $I}
          }
        }
      }
    }
  }

  End {
    return $ResultCollectionFiltered
  }

}

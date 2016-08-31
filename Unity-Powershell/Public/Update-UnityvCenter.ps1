Function Update-UnityvCenter {

  <#
      .SYNOPSIS
      Refresh vCenter hosts.
      .DESCRIPTION
      Refresh vCenter hosts.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specify an UnitySession Object.
      .PARAMETER ID
      ID or Object of a vCenter server
      .PARAMETER Refresh
      'Refresh all the hosts managed by the host container.
      .PARAMETER RefreshAll
      Refresh all known vCenters and ESX servers.
      .EXAMPLE
      Update-UnityvCenter -ID '' -Refresh

      Refresh all the hosts managed by this vCenter.
  #>

  [CmdletBinding(DefaultParameterSetName="Refresh")]
  Param (
    #Default Parameters
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),

    #vCenter
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'ID or Object of a vCenter server')]
    $ID,
    [Parameter(Mandatory = $true,ParameterSetName="Refresh",HelpMessage = 'Refresh all the hosts managed by the host container.')]
    [switch]$Refresh,
    [Parameter(Mandatory = $true,ParameterSetName="RefreshAll",HelpMessage = 'Refresh all known vCenters and ESX servers.')]
    [Switch]$RefreshAll
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"

    #Initialazing arrays
    $ResultCollection = @()
  }

  Process {
    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      Foreach ($i in $ID) {

        Write-Verbose "Input object type is $($ID.GetType().Name)"
        Switch ($i.GetType().Name)
        {
          "String" {
            $vCenterServer = get-UnityvCenter -Session $Sess -ID $i
            $vCenterServerID = $vCenterServer.id
          }
          "UnityvCenterServer" {
            $vCenterServerID = $i.id
          }
        }

        # Creation of the body hash
        $body = @{}

        # serviceType parameter
        $body["doRescan"] = $True

        If ($Sess.TestConnection()) {

          #Building the URI
          Switch ($PsCmdlet.ParameterSetName) {
            'Refresh' {
              $URI = 'https://'+$sess.Server+'/api/instances/hostContainer/'+$vCenterServerID+'/action/refresh'
            }
            'RefreshAll' {
              $URI = 'https://'+$sess.Server+'/api/types/hostContainer/action/refreshAll'
            }
          }

          Write-Verbose "URI: $URI"

          #Sending the request
          $request = Send-UnityRequest -uri $URI -Session $Sess -Method 'POST' -Body $Body

          Write-Verbose "Request status code: $($request.StatusCode)"

          If ($request.StatusCode -eq '204') {

            Write-Information -MessageData "vCenter(s) refreshed successfully"
            
          }
        } else {
          Write-Warning "You are no longer connected to EMC Unity array: $($Sess.Server)"
        }
      }
    }
  }

  End {}
}

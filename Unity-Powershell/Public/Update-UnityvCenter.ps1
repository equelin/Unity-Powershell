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
    [UnitySession[]]$session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),

    #vCenter
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'ID or Object of a vCenter server')]
    [String[]]$ID,
    [Parameter(Mandatory = $true,ParameterSetName="Refresh",HelpMessage = 'Refresh all the hosts managed by the host container.')]
    [switch]$Refresh,
    [Parameter(Mandatory = $true,ParameterSetName="RefreshAll",HelpMessage = 'Refresh all known vCenters and ESX servers.')]
    [Switch]$RefreshAll
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"

    # Variables
    $URI = '/api/instances/storageResource/<id>/action/modifyLun'
    $Type = 'vCenter'
    $TypeName = 'UnityvCenterServer'
    $StatusCode = 204
  }

  Process {
    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If ($Sess.TestConnection()) {

      Foreach ($i in $ID) {

        Switch ($i.GetType().Name)
        {
          "String" {
            $Object = get-UnityvCenter -Session $Sess -ID $i
            $ObjectID = $Object.id
            If ($Object.Name) {
              $ObjectName = $Object.Name
            } else {
              $ObjectName = $ObjectID
            }
          }
          "$TypeName" {
            Write-Verbose "Input object type is $($i.GetType().Name)"
            $ObjectID = $i.id
            If ($Object = Get-UnityvCenter -Session $Sess -ID $ObjectID) {
              If ($Object.Name) {
                $ObjectName = $Object.Name
              } else {
                $ObjectName = $ObjectID
              }          
            }
          }
        }

        If ($ObjectID) {

          # Creation of the body hash
          $body = @{}

          # serviceType parameter
          $body["doRescan"] = $True

            #Building the URI
            Switch ($PsCmdlet.ParameterSetName) {
              'Refresh' {
                $URI = 'https://'+$sess.Server+'/api/instances/hostContainer/'+$ObjectID+'/action/refresh'
              }
              'RefreshAll' {
                $URI = 'https://'+$sess.Server+'/api/types/hostContainer/action/refreshAll'
              }
            }

            Write-Verbose "URI: $URI"

            #Sending the request
            $request = Send-UnityRequest -uri $URI -Session $Sess -Method 'POST' -Body $Body

            If ($request.StatusCode -eq $StatusCode) {

                Write-Verbose "$Type with ID $ObjectID has been refreshed"

                Get-UnityvCenter -Session $Sess -ID $ObjectID
              
              }  # End If ($request.StatusCode -eq $StatusCode)
            } else {
            Write-Warning -Message "$Type with ID $i does not exist on the array $($sess.Name)"
          } # End If ($ObjectID)
        } # End Foreach ($i in $ID)
      } # End If ($Sess.TestConnection()) 
    } # End Foreach ($sess in $session)
  } # End Process
} # End Function

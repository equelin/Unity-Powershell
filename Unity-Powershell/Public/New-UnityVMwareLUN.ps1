Function New-UnityVMwareLUN {

  <#
      .SYNOPSIS
      Creates a Unity VMware block LUN.
      .DESCRIPTION
      Creates a Unity VMware block LUN.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under Apache licence
      .LINK
      https://github.com/equelin/Unity-Powershell
      .EXAMPLE
      New-UnityVMwareLUN -Name 'DATASTORE01' -Pool 'pool_1' -Size 10737418240

      Create LUN named 'LUN01' on pool 'pool_1' and with a size of '10737418240' bytes
  #>

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
    [bool]$isThinEnabled = $true,
    [Parameter(Mandatory = $false,HelpMessage = 'ID of a protection schedule to apply to the storage resource')]
    [String]$snapSchedule,
    [Parameter(Mandatory = $false,HelpMessage = 'Is assigned snapshot schedule is paused ? (Default is false)')]
    [bool]$isSnapSchedulePaused = $false
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"
  }

  Process {
    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

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

        $body["lunParameters"] = $lunParameters

        #snapScheduleParameters
        If ($snapSchedule) {
          $body["snapScheduleParameters"] = @{}
          $snapScheduleParameters = @{}
          $snapScheduleParam = @{}
          $snapScheduleParam["id"] ="$($snapSchedule)"
          $snapScheduleParameters["snapSchedule"] = $snapScheduleParam
          $snapScheduleParameters["isSnapSchedulePaused"]= "$($isSnapSchedulePaused)"
          $body["snapScheduleParameters"] = $snapScheduleParameters
        }

        # isThinEnabled
        If ($isThinEnabled) {
          $lunParameters["isThinEnabled"] = $isThinEnabled
        }

        If (Test-UnityConnection -Session $Sess) {

          #Building the URI
          $URI = 'https://'+$sess.Server+'/api/types/storageResource/action/createVmwareLun'
          Write-Verbose "URI: $URI"

          #Sending the request
          $request = Send-UnityRequest -uri $URI -Session $Sess -Method 'POST' -Body $Body

          Write-Verbose "Request status code: $($request.StatusCode)"

          If ($request.StatusCode -eq '200') {

            #Formating the result. Converting it from JSON to a Powershell object
            $results = ($request.content | ConvertFrom-Json).content.storageResource

            Write-Verbose "LUN created with the storage resource ID: $($results.id) "

            #Executing Get-UnityVMwareLUN with the ID of the new user
            Get-UnityVMwareLUN -Session $Sess -Name $n
          }
        } else {
          Write-Information -MessageData "You are no longer connected to EMC Unity array: $($Sess.Server)"
        }
      }
    }
  }

  End {
  }
}

Function New-UnitySnapSchedule {

  <#
      .SYNOPSIS
      Creates a new snapshot schedule.
      .DESCRIPTION
      Creates a new snapshot schedule.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specify an UnitySession Object.
      .PARAMETER Name
      Name of new schedule.
      .PARAMETER type
      Type of snapshot schedule rule. Values are:
      - N_HOURS_AT_MM: Snap every <interval> hours, at <minutes> past the hour. Supported parameters: interval (required), minutes (optional, default 0). 
      - DAY_AT_HHMM: Specify a list of <hour[,...]> to snap one or more times each day at <minutes> past the hour. Supported parameters: hours (at least one required), minutes (optional).  
      - N_DAYS_AT_HHMM: Snap every <interval> days at the time <hours>:<minutes>. Supported Parameters: interval (required), hours (optional, exactly one), minutes (optional). 
      - SELDAYS_AT_HHMM: Snap on the selected <daysOfWeek>, at the time <hours>:<minutes>. Supported parameters: daysOfWeek (at least one required), hours (optional, default 0), minutes (optional, default 0). 
      - NTH_DAYOFMONTH_AT_HHMM: Snap on the selected <daysOfMonth>, at the time <hours>:<minutes>. Supported parameters: daysOfMonth (at least one required), hours (optional, default 0), minutes (optional, default 0). 
      .PARAMETER minute
      Minute frequency for the snapshot schedule rule.
      .PARAMETER hours
      Hourly frequency for the snapshot schedule rule.
      .PARAMETER daysOfWeek
      Days of the week for which the snapshot schedule rule applies.
      .PARAMETER daysOfMonth
      Days of the month for which the snapshot schedule rule applies.
      .PARAMETER interval
      Number of days or hours between snaps, depending on the rule type.
      .PARAMETER isAutoDelete
      Indicates whether the system can automatically delete the snapshot based on pool automatic-deletion thresholds. Values are:
      - $True: System can delete the snapshot based on pool automatic-deletion thresholds.
      - $False: System cannot delete the snapshot based on pool automatic-deletion thresholds.
      .PARAMETER retentionTime
      (Applies when the value of the isAutoDelete attribute is false.) Period of time in seconds for which to keep the snapshot.
      .PARAMETER accessType
      For a file system or VMware NFS datastore snapshot schedule, indicates whether the snapshot created by the schedule has checkpoint or protocol type access
      .PARAMETER Confirm
      If the value is $true, indicates that the cmdlet asks for confirmation before running. If the value is $false, the cmdlet runs without asking for user confirmation.
      .PARAMETER WhatIf
      Indicate that the cmdlet is run only to display the changes that would be made and actually no objects are modified.
      .EXAMPLE
      New-UnitySnapSchedule -Name 'SCHEDULE01' -Type N_HOURS_AT_MM -Interval 12 -Minute 30

      Create snapshot schedule named 'SCHEDULE01'. Snap every 12 hours, at 30 minutes past the hour.
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    #Default Parameters
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    
    #UnitySnapSchedule
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Name of new schedule')]
    [String[]]$name,

    #UnitySnapScheduleRule
    [Parameter(Mandatory = $true,HelpMessage = 'Type of snapshot schedule rule.')]
    [ScheduleTypeEnum]$type,
    [Parameter(Mandatory = $false,HelpMessage = 'Minute frequency for the snapshot schedule rule.')]
    [UInt32]$minute,
    [Parameter(Mandatory = $false,HelpMessage = 'Hourly frequency for the snapshot schedule rule.')]
    [UInt32[]]$hours,
    [Parameter(Mandatory = $false,HelpMessage = 'Days of the week for which the snapshot schedule rule applies.')]
    [DayOfWeekEnum[]]$daysOfWeek,
    [Parameter(Mandatory = $false,HelpMessage = 'Days of the month for which the snapshot schedule rule applies.')]
    [UInt32]$daysOfMonth,
    [Parameter(Mandatory = $false,HelpMessage = 'Number of days or hours between snaps, depending on the rule type.')]
    [UInt32]$interval,
    [Parameter(Mandatory = $false,HelpMessage = 'Indicates whether the system can automatically delete the snapshot based on pool automatic-deletion thresholds.')]
    [bool]$isAutoDelete,
    [Parameter(Mandatory = $false,HelpMessage = '(Applies when the value of the isAutoDelete attribute is false.) Period of time in seconds for which to keep the snapshot.')]
    [UInt64]$retentionTime,
    [Parameter(Mandatory = $false,HelpMessage = 'For a file system or VMware NFS datastore snapshot schedule, indicates whether the snapshot created by the schedule has checkpoint or protocol type access.')]
    [FilesystemSnapAccessTypeEnum]$accessType
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    ## Variables
    $URI = '/api/types/snapSchedule/instances'
    $TypeName = 'Schedule'
    $StatusCode = 201
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      Foreach ($n in $name) {

        #### REQUEST BODY 

        # Creation of the body hash
        $body = @{}

        $body["name"] = $n

        $body["rules"] = @()
        $snapScheduleRule = @{}
        
        $snapScheduleRule["type"] = $type

        If ($PSBoundParameters.ContainsKey('minute')) {
              $snapScheduleRule["minute"] = $minute
        }

        If ($PSBoundParameters.ContainsKey('hours')) {
              $snapScheduleRule["hours"] = @()
              $hoursParameters += $hours
              $snapScheduleRule["hours"] = $hoursParameters 
        }

        If ($PSBoundParameters.ContainsKey('daysOfWeek')) {
              $snapScheduleRule["daysOfWeek"] = $daysOfWeek
        }

        If ($PSBoundParameters.ContainsKey('daysOfMonth')) {
              $snapScheduleRule["daysOfMonth"] = $daysOfMonth
        }

        If ($PSBoundParameters.ContainsKey('interval')) {
              $snapScheduleRule["interval"] = $interval
        }

        If ($PSBoundParameters.ContainsKey('isAutoDelete')) {
              $snapScheduleRule["isAutoDelete"] = $isAutoDelete
        }

        If ($PSBoundParameters.ContainsKey('retentionTime')) {
              $snapScheduleRule["retentionTime"] = $retentionTime
        }
        
        If ($PSBoundParameters.ContainsKey('accessType')) {
              $snapScheduleRule["accessType"] = $accessType
        }

        $body["rules"] += $snapScheduleRule

        ####### END BODY - Do not edit beyond this line

        #Show $body in verbose message
        $Json = $body | ConvertTo-Json -Depth 10
        Write-Verbose $Json  

        If ($Sess.TestConnection()) {

          ##Building the URL
          $URL = 'https://'+$sess.Server+$URI
          Write-Verbose "URL: $URL"

          #Sending the request
          If ($pscmdlet.ShouldProcess($Sess.Name,"Create $TypeName")) {
            $request = Send-UnityRequest -uri $URL -Session $Sess -Method 'POST' -Body $Body
          }

          Write-Verbose "Request status code: $($request.StatusCode)"

          If ($request.StatusCode -eq $StatusCode) {

            #Formating the result. Converting it from JSON to a Powershell object
            $results = ($request.content | ConvertFrom-Json).content

            Write-Verbose "$Type with the ID $($results.id) has been created"

            Get-UnitySnapSchedule -Session $Sess -ID $results.id
          } # End If ($request.StatusCode -eq $StatusCode)
        } # End If ($Sess.TestConnection()) 
      } # End Foreach
    } # End Foreach ($sess in $session)
  } # End Process
} # End Function
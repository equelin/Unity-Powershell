Function Set-UnitySnapSchedule {

  <#
      .SYNOPSIS
      Modifies snapshot schedule parameters.
      .DESCRIPTION
      Modifies snapshot schedule parameters. You can add or delete rules. Rules can be added one at a time.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specify an UnitySession Object.
      .PARAMETER Confirm
      If the value is $true, indicates that the cmdlet asks for confirmation before running. 
      If the value is $false, the cmdlet runs without asking for user confirmation.
      .PARAMETER WhatIf
      Indicate that the cmdlet is run only to display the changes that would be made and actually no objects are modified.
      .PARAMETER ID
      ID of the snapshot Schedule or snapshot Schedule Object.
      .PARAMETER addRules
      Rules to add to the snapshot schedule.
      .PARAMETER removeRuleIds
      ID of the rules to remove from the snapshot schedule.
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
      .EXAMPLE
      Set-UnitySnapSchedule -ID 'snapSch_6' -addRules -Type N_HOURS_AT_MM -Interval 12 -Minutes 30

      Add rule to snapshot schedule with ID 'snapSch_6'. Snap every 12 hours, at 30 minutes past the hour.
      .EXAMPLE
      Set-UnitySnapSchedule -ID 'snapSch_6' -removeRuleIds 'SchedRule_11'

      Remove rule ID 'SchedRule_11' to snapshot schedule with ID 'snapSch_6'.
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High',DefaultParameterSetName="addRules")]
  Param (
    #Default Parameters
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),

    
    [Parameter(Mandatory = $true,ParameterSetName="addRules",Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'ID of the snapshot Schedule or snapshot Schedule Object.')]
    [Parameter(Mandatory = $true,ParameterSetName="removeRuleIds",Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'ID of the snapshot Schedule or snapshot Schedule Object.')]
    [Object[]]$ID,

    # Add rules
    [Parameter(Mandatory = $true,ParameterSetName="addRules",HelpMessage = 'Unique identifiers of the rules to remove from the snapshot schedule.')]
    [switch]$addRules,
    [Parameter(Mandatory = $true,ParameterSetName="addRules",HelpMessage = 'Type of snapshot schedule rule.')]
    [ScheduleTypeEnum]$type,
    [Parameter(Mandatory = $false,ParameterSetName="addRules",HelpMessage = 'Minute frequency for the snapshot schedule rule.')]
    [UInt32]$minute,
    [Parameter(Mandatory = $false,ParameterSetName="addRules",HelpMessage = 'Hourly frequency for the snapshot schedule rule.')]
    [UInt32[]]$hours,
    [Parameter(Mandatory = $false,ParameterSetName="addRules",HelpMessage = 'Days of the week for which the snapshot schedule rule applies.')]
    [DayOfWeekEnum[]]$daysOfWeek,
    [Parameter(Mandatory = $false,ParameterSetName="addRules",HelpMessage = 'Days of the month for which the snapshot schedule rule applies.')]
    [UInt32]$daysOfMonth,
    [Parameter(Mandatory = $false,ParameterSetName="addRules",HelpMessage = 'Number of days or hours between snaps, depending on the rule type.')]
    [UInt32]$interval,
    [Parameter(Mandatory = $false,ParameterSetName="addRules",HelpMessage = 'Indicates whether the system can automatically delete the snapshot based on pool automatic-deletion thresholds.')]
    [bool]$isAutoDelete,
    [Parameter(Mandatory = $false,ParameterSetName="addRules",HelpMessage = '(Applies when the value of the isAutoDelete attribute is false.) Period of time in seconds for which to keep the snapshot.')]
    [UInt64]$retentionTime,
    [Parameter(Mandatory = $false,ParameterSetName="addRules",HelpMessage = 'For a file system or VMware NFS datastore snapshot schedule, indicates whether the snapshot created by the schedule has checkpoint or protocol type access.')]
    [FilesystemSnapAccessTypeEnum]$accessType,

    # Remove rules ID
    [Parameter(Mandatory = $true,ParameterSetName="removeRuleIds",HelpMessage = 'Unique identifiers of the rules to remove from the snapshot schedule.')]
    [string[]]$removeRuleIds
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    # Variables
    $URI = '/api/instances/snapSchedule/<id>/action/modify'
    $ObjectType = 'Snapshot Schedule'
    $TypeName = 'UnitySnapSchedule'
    $StatusCode = 204
  }

  Process {

    Foreach ($sess in $session) {

      Write-Debug -Message "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If ($Sess.TestConnection()) {

        Foreach ($i in $ID) {

          # Determine input and convert to object if necessary
          $Object,$ObjectID,$ObjectName = Get-UnityObject -Data $i -Typename $Typename -Session $Sess

          If ($ObjectID) {

            #### REQUEST BODY 

            # Creation of the body hash
            $body = @{}

            Switch ($PsCmdlet.ParameterSetName) {
              'addRules' {


                $body["addRules"] = @()
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

                $body["addRules"] += $snapScheduleRule

              }
              'removeRuleIds' {
                If ($PSBoundParameters.ContainsKey('removeRuleIds')) {
                  $body["removeRuleIds"] = @()

                  $body["removeRuleIds"] += $removeRuleIds

                }
              }
            }

            ####### END BODY - Do not edit beyond this line

            #Show $body in verbose message
            $Json = $body | ConvertTo-Json -Depth 10
            Write-Verbose $Json 

            #Building the URL
            $FinalURI = $URI -replace '<id>',$ObjectID

            $URL = 'https://'+$sess.Server+$FinalURI
            Write-Verbose "URL: $URL"

            #Sending the request
            If ($pscmdlet.ShouldProcess($Sess.Name,"Modify $ObjectType $ObjectName")) {
              $request = Send-UnityRequest -uri $URL -Session $Sess -Method 'POST' -Body $Body
            }

            If ($request.StatusCode -eq $StatusCode) {

              Write-Verbose "$ObjectType with ID $ObjectID has been modified"

              Get-UnitySnapSchedule -Session $Sess -id $ObjectID

            }  # End If ($request.StatusCode -eq $StatusCode)
          } else {
            Write-Warning -Message "$Type with ID $i does not exist on the array $($sess.Name)"
          } # End If ($ObjectID)
        } # End Foreach ($i in $ID)
      } # End If ($Sess.TestConnection()) 
    } # End Foreach ($sess in $session)
  } # End Process
} # End Function

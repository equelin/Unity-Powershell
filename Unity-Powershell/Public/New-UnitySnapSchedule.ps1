Function New-UnitySnapSchedule {

  <#
      .SYNOPSIS
      Creates a new snapshot.
      .DESCRIPTION
      Creates a new snapshot.
      Creating a snapshot creates a new point-in-time view of a block or file resource associated with the point-in-time at which the snapshot was taken. 
      Immediately after being created, a snapshot consumes almost no space for the pool as it still shares all of its blocks with the primary block or file resource.
      However as new data is written to the parent resource, redirects occur as discussed previously, and the snapshot begins to consume pool space that is not also associated with the current production version of the parent resource. 
      Once a snapshot is created, it is available to perform snapshot operations on such as restoring, copying, attaching/detaching, or deleting.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specify an UnitySession Object.
      .PARAMETER Name
      Name of new schedule.



      .PARAMETER Confirm
      If the value is $true, indicates that the cmdlet asks for confirmation before running. If the value is $false, the cmdlet runs without asking for user confirmation.
      .PARAMETER WhatIf
      Indicate that the cmdlet is run only to display the changes that would be made and actually no objects are modified.
      .EXAMPLE
      New-UnitySnapSchedule -StorageResource 'res_41' -Name 'snap01'

      Create snap named 'snap01' from sorage resource ID 'res_41'
      .EXAMPLE
      Get-UnityVMwareNFS -Name 'VOLUME01' | New-UnitySnapSchedule

      Create a snapshot of the VMware NFS volume.
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High',DefaultParameterSetName="RaidGroup")]
  Param (
    #Default Parameters
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    [UnitySession[]]$session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    
    #UnitySnapSchedule
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Name of new schedule')]
    [String]$name,

    #UnitySnapScheduleRule
    [Parameter(Mandatory = $false,HelpMessage = 'Type of snapshot schedule rule')]
    [ScheduleTypeEnum]$type,
    [UInt32]$minute,
    [UInt32]$hours,
    [DayOfWeekEnum[]]$daysOfWeek,
    [UInt32]$daysOfMonth,
    [UInt32]$interval,
    [bool]$isAutoDelete,
    [UInt64]$retentionTime,
    [FilesystemSnapAccessTypeEnum]$accessType
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"

    ## Variables
    $URI = '/api/types/snapSchedule/instances'
    $Type = 'Schedule'
    $StatusCode = 201
  }

  Process {
    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      Foreach ($n in $name) {

        #### REQUEST BODY 

        # Creation of the body hash
        $body = @{}

        $body["storageResource"] = @{}
        $storageResourceParameter = @{}
        $storageResourceParameter["id"] = $ObjectID
        $body["storageResource"] = $storageResourceParameter

        If ($PSBoundParameters.ContainsKey('name')) {
              $body["name"] = $name
        }

        If ($PSBoundParameters.ContainsKey('description')) {
              $body["description"] = $description
        }

        If ($PSBoundParameters.ContainsKey('isAutoDelete')) {
              $body["isAutoDelete"] = $isAutoDelete
        }

        If ($PSBoundParameters.ContainsKey('retentionDuration')) {
              $body["retentionDuration"] = $retentionDuration
        }

        If ($PSBoundParameters.ContainsKey('isReadOnly')) {
              $body["isReadOnly"] = $isReadOnly
        }

        If ($PSBoundParameters.ContainsKey('filesystemAccessType')) {
              $body["filesystemAccessType"] = $filesystemAccessType
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
          If ($pscmdlet.ShouldProcess($Sess.Name,"Create $Type on storage resource ID $ObjectID")) {
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
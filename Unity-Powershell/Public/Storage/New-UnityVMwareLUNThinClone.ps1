Function New-UnityVMwareLUNThinClone {

    <#
        .SYNOPSIS
        Creates a VMware datastore thin clone.
        .DESCRIPTION
        Creates a VMware datastore thin clone.
        .NOTES
        Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
        .LINK
        https://github.com/equelin/Unity-Powershell
        .PARAMETER Session
        Specify an UnitySession Object.
        .PARAMETER VMwareLUN
        VMware LUN id
        .PARAMETER Snap
        The reference to the source snapshot ID object.
        .PARAMETER Name
        Name for the new Thin Clone, unique to the system.
        .PARAMETER Description
        Description of the Thin clone.
        .PARAMETER host
        List of host to grant access to the thin clone.
        .PARAMETER accessMask
        Host access mask. Might be:
        - NoAccess: No access. 
        - Production: Access to production LUNs only. 
        - Snapshot: Access to LUN snapshots only. 
        - Both: Access to both production LUNs and their snapshots.
        .PARAMETER snapSchedule
        Snapshot schedule assigned to the thin clone
        .PARAMETER isSnapSchedulePaused
        Indicates whether the assigned snapshot schedule is paused.
        .PARAMETER Confirm
        If the value is $true, indicates that the cmdlet asks for confirmation before running. If the value is $false, the cmdlet runs without asking for user confirmation.
        .PARAMETER WhatIf
        Indicate that the cmdlet is run only to display the changes that would be made and actually no objects are modified.
        .EXAMPLE
        $Snap = Get-UnityVMwareLUN -Name 'Datastore01' | New-UnitySnap -isAutoDelete:$false
        New-UnityVMwareLUNThinClone -VMwareLUN sv_79 -snap $snap.id -name 'Datastore01-Thinclone' -snapSchedule 'snapSch_1' -host 'Host_36','Host_37'
    #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    #Default Parameters
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    
    #UnityVMwareLUNThinClone
    [Parameter(Mandatory = $true,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'VMwar LUN ID or object.')]
    [Object]$VMwareLUN,
    [Parameter(Mandatory = $true,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Storage resource ID or object.')]
    [Object]$snap,
    [Parameter(Mandatory = $true,HelpMessage = 'Name for the new thin clone')]
    [String]$name,
    [Parameter(Mandatory = $false,HelpMessage = 'Description for new thin clone')]
    [String]$Description,

    # lunParameters
    [Parameter(Mandatory = $false,HelpMessage = 'IO limit policy ID that applies to the storage resource.')]
    $ioLimitPolicy,	
    [Parameter(Mandatory = $false,HelpMessage = 'Host to grant access to LUN')]
    [String[]]$host,
    [Parameter(Mandatory = $false,HelpMessage = 'Host access mask')]
    [HostLUNAccessEnum]$accessMask = 'Production',

    # snapScheduleParameters
    [Parameter(Mandatory = $false,HelpMessage = 'ID of a protection schedule to apply to the storage resource')]
    [String]$snapSchedule,
    [Parameter(Mandatory = $false,HelpMessage = 'Is assigned snapshot schedule is paused ? (Default is false)')]
    [bool]$isSnapSchedulePaused = $false
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand.Name)] Executing function"
    Write-Debug -Message "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
    Write-Debug -Message "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

    ## Variables
    $URI = '/api/instances/storageResource/<id>/action/createVmwareLunThinClone'
    $Type = 'ThinClone'
    $StatusCode = 200
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      # Determine input and convert to object if necessary

      Write-Verbose "Input object type is $($VMwareLUN.GetType().Name)"
      Switch ($VMwareLUN.GetType().Name)
      {
        "UnityVMwareLUN" {
          $ObjectID = $VMwareLUN.storageResource.id
        }

        "String" {
          If ($Object = Get-UnityVMwareLUN -Session $Sess -ID $VMwareLUN -ErrorAction SilentlyContinue) {
            $ObjectID = $Object.storageResource.id
          } else {
            Throw "This LUN does not exist"
          }
        }
      }

      #### REQUEST BODY 

      # Creation of the body hash
      $body = @{}

      #Snap
      $body["snap"] = @{}
        $snapParameter = @{}
        $snapParameter["id"] = $snap
      $body["snap"] = $snapParameter

      #Name
      $body["name"] = $name

      #Description
      If ($PSBoundParameters.ContainsKey('description')) {
            $body["description"] = $description
      }

      #lunParameters parameter
      If ($PSBoundParameters.ContainsKey('host')) {
          $body["lunParameters"] = @{}
          $lunParameters = @{}

          $lunParameters["hostAccess"] = @()
          $hostAccess = @()

          foreach ($h in $host) {
            $blockHostAccessParam = @{}
              $blockHostAccessParam['host'] = @{}
                $HostParam = @{}
                $HostParam['id'] = $h
              $blockHostAccessParam['host'] = $HostParam
              $blockHostAccessParam['accessMask'] = $accessMask
            $hostAccess += $blockHostAccessParam
          }

          $lunParameters["hostAccess"] = $hostAccess

          $body["lunParameters"] = $lunParameters
      }

        #snapScheduleParameters
        If ($PSBoundParameters.ContainsKey('snapSchedule')) {
            $body["snapScheduleParameters"] = @{}
                $snapScheduleParameters = @{}
                    $snapScheduleParam = @{}
                    $snapScheduleParam["id"] ="$($snapSchedule)"
                $snapScheduleParameters["snapSchedule"] = $snapScheduleParam
                $snapScheduleParameters["isSnapSchedulePaused"]= "$($isSnapSchedulePaused)"
            $body["snapScheduleParameters"] = $snapScheduleParameters
        }

      ####### END BODY - Do not edit beyond this line

      #Show $body in verbose message
      $Json = $body | ConvertTo-Json -Depth 10
      Write-Verbose $Json  

      If ($Sess.TestConnection()) {

        #Building the URL
        $FinalURI = $URI -replace '<id>',$ObjectID

        ##Building the URL
        $URL = 'https://'+$sess.Server+$FinalURI
        Write-Verbose "URL: $URL"

        #Sending the request
        If ($pscmdlet.ShouldProcess($Sess.Name,"Create $Type on VMware LUN ID $ObjectID")) {
          $request = Send-UnityRequest -uri $URL -Session $Sess -Method 'POST' -Body $Body
        }

        Write-Verbose "Request status code: $($request.StatusCode)"

        Write-Debug -Message "[$($MyInvocation.MyCommand.Name)] Request result: $($request | Out-String)"

        If ($request.StatusCode -eq $StatusCode) {

          #Formating the result. Converting it from JSON to a Powershell object
          $results = ($request.content | ConvertFrom-Json).content

          Write-Verbose "$Type with the ID $($results.storageResource.id) has been created"

          Get-UnityVMwareLUN -Session $Sess | Where-Object {$_.storageResource.id -eq $results.storageResource.id}
        } # End If ($request.StatusCode -eq $StatusCode)
      } # End If ($Sess.TestConnection()) 

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function
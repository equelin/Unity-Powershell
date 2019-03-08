Function New-UnityTreeQuota {

  <#
      .SYNOPSIS
      Creates a Unity TreeQuota.
      .DESCRIPTION
      Creates a Unity TreeQuota.
      You need to have an active session with the array.
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specify an UnitySession Object.
      .PARAMETER Path
      TreeQuota Path
      .PARAMETER Description
      Filesystem Description
      .PARAMETER snapSchedule
      ID of a protection schedule to apply to the filesystem
      .PARAMETER isSnapSchedulePaused
      Is assigned snapshot schedule is paused ? (Default is false)
      .PARAMETER Pool
      Filesystem Pool ID
      .PARAMETER nasServer
      Filesystem nasServer ID
      .PARAMETER supportedProtocols
      Filesystem supported protocols
      .PARAMETER isFLREnabled
      Indicates whether File Level Retention (FLR) is enabled for the file system
      .PARAMETER isThinEnabled
      Indicates whether to enable thin provisioning for file system. Default is $True
      .PARAMETER Size
      Filesystem Size
      .PARAMETER hostIOSize
      Typical write I/O size from the host to the file system
      .PARAMETER isCacheDisabled
      Indicates whether caching is disabled
      .PARAMETER accessPolicy
      Access policy
      .PARAMETER poolFullPolicy
      Behavior to follow when pool is full and a write to this filesystem is attempted
      .PARAMETER tieringPolicy
      Filesystem tiering policy
      .PARAMETER isCIFSSyncWritesEnabled
      Indicates whether the CIFS synchronous writes option is enabled for the file system
      .PARAMETER isCIFSOpLocksEnabled
      Indicates whether opportunistic file locks are enabled for the file system
      .PARAMETER isCIFSNotifyOnWriteEnabled
      Indicates whether the system generates a notification when the file system is written to
      .PARAMETER isCIFSNotifyOnAccessEnabled
      Indicates whether the system generates a notification when a user accesses the file system
      .PARAMETER cifsNotifyOnChangeDirDepth
      Indicates the lowest directory level to which the enabled notifications apply, if any
      .PARAMETER Confirm
      If the value is $true, indicates that the cmdlet asks for confirmation before running. If the value is $false, the cmdlet runs without asking for user confirmation.
      .PARAMETER WhatIf
      Indicate that the cmdlet is run only to display the changes that would be made and actually no objects are modified.

      .EXAMPLE
      New-UnityFilesystem -Name 'FS01' -Pool 'pool_1' -Size 10GB -nasServer 'nas_1' -supportedProtocols 'CIFS'

      Create CIFS filesystem named 'FS01' on pool 'pool_1' and with a size of '10GB' bytes
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    
    #Default Parameters
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),

    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'TreeQuotaPath')]
    [String[]]$Path,
    [Parameter(Mandatory = $true,HelpMessage = 'Filesystem ID')]
    [String]$Filesystem,

    [Parameter(Mandatory = $false,HelpMessage = 'TreeQuota Description')]
    [String]$Description,
    [Parameter(Mandatory = $false,HelpMessage = 'TreeQuota hard limit')]
    [uint64]$HardLimit,
    [Parameter(Mandatory = $false,HelpMessage = 'TreeQuota soft limit')]
    [uint64]$SoftLimit
    
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    ## Variables
    $URI = '/api/types/treeQuota/instances'
    $Type = 'treeQuota'
    $StatusCode = 201
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      Foreach ($n in $Path) {

        #### REQUEST BODY 

        # Creation of the body hash
        $body = @{}

        # Path parameter
        $body["path"] = "$($n)"

        # Filesystem parameter
        $body["filesystem"] = @{}
        $filesystemArg = @{}
        $filesystemArg["id"] = "$($Filesystem)"
        $body["filesystem"] = $filesystemArg

        # Optional parameters
        If ($Description) {
              $body["description"] = "$($Description)"
        }

        If ($HardLimit) {
              $body["hardLimit"] = "$($HardLimit)"
        }

        If ($SoftLimit) {
              $body["softLimit"] = "$($SoftLimit)"
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
          If ($pscmdlet.ShouldProcess($Sess.Name,"Create $Type $n")) {
            $request = Send-UnityRequest -uri $URL -Session $Sess -Method 'POST' -Body $Body
          }

          Write-Verbose "Request status code: $($request.StatusCode)"

          If ($request.StatusCode -eq $StatusCode) {

            #Formating the result. Converting it from JSON to a Powershell object
            $results = ($request.content | ConvertFrom-Json).content

            Write-Verbose "$Type with the ID $($results.id) has been created"

            Get-UnityTreeQuota -session $Sess -ID $results.id
          } # End If ($request.StatusCode -eq $StatusCode)
        } # End If ($Sess.TestConnection()) 
      } # End Foreach
    } # End Foreach ($sess in $session)
  } # End Process
} # End Function

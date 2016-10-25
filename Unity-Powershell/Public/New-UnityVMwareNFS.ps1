Function New-UnityVMwareNFS {

  <#
      .SYNOPSIS
      Creates a Unity VMware NFS LUN.
      .DESCRIPTION
      Creates a Unity VMware NFS LUN.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specify an UnitySession Object.
      .PARAMETER Name
      VMware NFS LUN Name
      .PARAMETER Description
      VMware NFS LUN Description
      .PARAMETER snapSchedule
      ID of a protection schedule to apply to the VMware NFS LUN
      .PARAMETER isSnapSchedulePaused
      Is assigned snapshot schedule is paused ? (Default is false)
      .PARAMETER Pool
      VMware NFS LUN Pool ID
      .PARAMETER nasServer
      VMware NFS LUN nasServer ID
      .PARAMETER isThinEnabled
      Indicates whether to enable thin provisioning for VMware NFS LUN. Default is $True
      .PARAMETER Size
      VMware NFS LUN Size
      .PARAMETER hostIOSize
      Typical write I/O size from the host to the VMware NFS LUN
      .PARAMETER tieringPolicy
      VMware NFS LUN tiering policy
      .PARAMETER defaultAccess
      Default access level for all hosts accessing the VMware NFS LUN.
      .PARAMETER minSecurity
      Minimal security level that must be provided by a client to mount the VMware NFS LUN.
      .PARAMETER noAccessHosts
      Hosts with no access to the VMware NFS LUN or its snapshots, as defined by the host resource type.
      .PARAMETER readOnlyHosts
      Hosts with read-only access to the VMware NFS LUN and its snapshots, as defined by the host resource type.
      .PARAMETER rootAccessHosts
      Hosts with read-write access to the VMware NFS LUN and its snapshots, as defined by the host resource type.
      .PARAMETER rootAccessHosts
      Hosts with root access to the VMware NFS LUN and its snapshots, as defined by the host resource type.
      .PARAMETER Confirm
      If the value is $true, indicates that the cmdlet asks for confirmation before running. If the value is $false, the cmdlet runs without asking for user confirmation.
      .PARAMETER WhatIf
      Indicate that the cmdlet is run only to display the changes that would be made and actually no objects are modified.

      .EXAMPLE
      New-UnityVMwareNFS -Name 'FS01' -Pool 'pool_1' -Size 10GB -nasServer 'nas_1' -supportedProtocols 'CIFS'

      Create CIFS VMware NFS LUN named 'FS01' on pool 'pool_1' and with a size of '10GB' bytes
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    
    #Default Parameters
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),

    #Create VMware NFS LUN
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'VMware NFS LUN Name')]
    [String[]]$Name,
    [Parameter(Mandatory = $false,HelpMessage = 'VMware NFS LUN Description')]
    [String]$Description,

    #snapScheduleParameters
    [Parameter(Mandatory = $false,HelpMessage = 'ID of a protection schedule to apply to the VMware NFS LUN')]
    [String]$snapSchedule,
    [Parameter(Mandatory = $false,HelpMessage = 'Is assigned snapshot schedule is paused ? (Default is false)')]
    [bool]$isSnapSchedulePaused = $false,
    
    #fsParameters
    [Parameter(Mandatory = $true,HelpMessage = 'VMware NFS LUN Pool ID')]
    [String]$Pool,
    [Parameter(Mandatory = $true,HelpMessage = 'VMware NFS LUN nasServer ID')]
    [String]$nasServer,
    [Parameter(Mandatory = $false,HelpMessage = 'Indicates whether to enable thin provisioning for VMware NFS LUN')]
    [String]$isThinEnabled = $true,
    [Parameter(Mandatory = $true,HelpMessage = 'VMware NFS LUN Size')]
    [uint64]$Size,
    [Parameter(Mandatory = $false,HelpMessage = 'Typical write I/O size from the host to the VMware NFS LUN')]
    [HostIOSizeEnum]$hostIOSize,

    #$nfsShareParameters
    [Parameter(Mandatory = $false,HelpMessage = 'Default access level for all hosts accessing the NFS share.')]
    [NFSShareDefaultAccessEnum]$defaultAccess = 'NoAccess',
    [Parameter(Mandatory = $false,HelpMessage = 'Minimal security level that must be provided by a client to mount the NFS share.')]
    [NFSShareSecurityEnum]$minSecurity,
    [Parameter(Mandatory = $false,HelpMessage = 'Hosts with no access to the NFS share or its snapshots.')]
    [string[]]$noAccessHosts,
    [Parameter(Mandatory = $false,HelpMessage = 'Hosts with read-only access to the NFS share and its snapshots.')]
    [string[]]$readOnlyHosts,
    [Parameter(Mandatory = $false,HelpMessage = 'Hosts with read-write access to the NFS share and its snapshots.')]
    [string[]]$readWriteHosts,
    [Parameter(Mandatory = $false,HelpMessage = 'Hosts with root access to the NFS share and its snapshots.')]
    [string[]]$rootAccessHosts,

    ##fastVPParameterseters
    [Parameter(Mandatory = $false,HelpMessage = 'VMware NFS LUN tiering policy')]
    [TieringPolicyEnum]$tieringPolicy
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"

    ## Variables
    $URI = '/api/types/storageResource/action/createVmwareNfs'
    $Type = 'VMware NFS LUN'
    $StatusCode = 200
  }

  Process {
    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      Foreach ($n in $Name) {

        #### REQUEST BODY 

        # Creation of the body hash
        $body = @{}

        # Name parameter
        $body["name"] = "$($n)"

        # Description parameter
        If ($Description) {
              $body["description"] = "$($Description)"
        }

        # fsParameters parameter
        $body["fsParameters"] = @{}
          $fsParameters = @{}
            $poolParameters = @{}
            $poolParameters["id"] = "$($Pool)"
          $fsParameters["pool"] = $poolParameters
        
          $nasServerParameters = @{}
            $nasServerParameters["id"] = "$($nasServer)"
          $fsParameters["nasServer"] = $nasServerParameters

          $fsParameters["size"] = $($Size)
          
          # isThinEnabled
          If ($PSBoundParameters.ContainsKey('isThinEnabled')) {
            $fsParameters["isThinEnabled"] = $isThinEnabled
          }

          # hostIOSize
          If ($PSBoundParameters.ContainsKey('hostIOSize')) {
            $fsParameters["hostIOSize"] = $hostIOSize
          }

          # fastVPParameters
          If ($PSBoundParameters.ContainsKey('tieringPolicy')) {
            $fastVPParameters = @{}
            $fastVPParameters['tieringPolicy'] = $tieringPolicy
            $fsParameters["fastVPParameters"] = $fastVPParameters
          }

        $body["fsParameters"] = $fsParameters

        #nfsShareParameters
        $body["nfsShareParameters"] = @{}
          
          $nfsShareParameters = @{}

          $nfsShareParameters["defaultAccess"] = $defaultAccess          

          If ($PSBoundParameters.ContainsKey('minSecurity')) {
            $nfsShareParameters["minSecurity"] = $minSecurity
          }

          If ($PSBoundParameters.ContainsKey('noAccessHosts')) {
          
            $nfsShareParameters["noAccessHosts"] = @()

            foreach ($h in $noAccessHosts) {

                  $HostParam = @{}
                  $HostParam['id'] = $h

              $nfsShareParameters["noAccessHosts"] += $HostParam
            }
          }

          If ($PSBoundParameters.ContainsKey('readOnlyHosts')) {
          
            $nfsShareParameters["readOnlyHosts"] = @()

            foreach ($h in $readOnlyHosts) {

                  $HostParam = @{}
                  $HostParam['id'] = $h

              $nfsShareParameters["readOnlyHosts"] += $HostParam
            }
          }

          If ($PSBoundParameters.ContainsKey('readWriteHosts')) {
          
            $nfsShareParameters["readWriteHosts"] = @()

            foreach ($h in $readWriteHosts) {

                  $HostParam = @{}
                  $HostParam['id'] = $h

              $nfsShareParameters["readWriteHosts"] += $HostParam
            }
          }

          If ($PSBoundParameters.ContainsKey('rootAccessHosts')) {
          
            $nfsShareParameters["rootAccessHosts"] = @()

            foreach ($h in $rootAccessHosts) {

                  $HostParam = @{}
                  $HostParam['id'] = $h

              $nfsShareParameters["rootAccessHosts"] += $HostParam
            }
          }

        $body["nfsShareParameters"] = $nfsShareParameters
        
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

            $Storageresource = Get-UnitystorageResource -session $Sess -ID $results.storageResource.id

            Write-Verbose "$Type with the ID $($Storageresource.filesystem.id) has been created"

            Get-UnityVMwareNFS -Session $Sess -ID $Storageresource.filesystem.id
          } # End If ($request.StatusCode -eq $StatusCode)
        } # End If ($Sess.TestConnection()) 
      } # End Foreach
    } # End Foreach ($sess in $session)
  } # End Process
} # End Function

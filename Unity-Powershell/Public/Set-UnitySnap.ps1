Function Set-UnitySnap {

  <#
      .SYNOPSIS
      Modifies snapshot parameters.
      .DESCRIPTION
      Modifies snapshot parameters.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specify an UnitySession Object.
      .PARAMETER ID
      Snapshot ID or Object.
      .PARAMETER Name
      Snapshot name (Applies to block type storage resource snaps only. Filesystem snapshot names cannot be modified).
      .PARAMETER Description
      Snapshot description.
      .PARAMETER isAutoDelete
      Indicates whether the system will automatically delete the snapshot when the pool snapshot space or total pool space reaches an automatic deletion threshold.
      .PARAMETER retentionDuration
      How long (in seconds) to keep the snapshot (Can be specified only if auto delete is set to false).
      .PARAMETER ioLimitParameters
      The IO limit policy that is applied to this snapshot. This is only applicable to attached snapshots.
      .PARAMETER copyName
      Base name for the new snapshot copies or Name of the backup snapshot created before the restore/attach operation occurs.
      .PARAMETER numCopies
      Number of snapshot copies to make.
      .PARAMETER copyStartNum
      Starting number for the group of copies. This number gets appended to the name specified in the copyName argument to form the name of the first snapshot copy. The system increments the number for each new snapshot.
      .PARAMETER copy
      Copy a snapshot.
      .PARAMETER restore
      Restore the snapshot to the associated storage resource. 
      .PARAMETER attach
      Attach the snapshot so hosts can access it. Attaching a snapshot makes the snapshot accessible to configured hosts for restoring files and data.
      .PARAMETER detach
      Detach the snapshot so hosts can no longer access it.
      .PARAMETER Confirm
      If the value is $true, indicates that the cmdlet asks for confirmation before running. If the value is $false, the cmdlet runs without asking for user confirmation.
      .PARAMETER WhatIf
      Indicate that the cmdlet is run only to display the changes that would be made and actually no objects are modified.
      .EXAMPLE
      Set-UnitySnap -ID '171798691854' -Description 'Modified description'

      Change the description of the snapshot with ID '171798691854'
      .EXAMPLE
      Set-UnitySnap -ID '171798691854' -Copy -numCopies 2

      Copy 2 times the snapshot with ID '171798691854'
      .EXAMPLE
      Set-UnitySnap -ID '171798691854' -Restore

      Restore the snapshot with ID '171798691854' to the associated storage resource.
      .EXAMPLE
      Set-UnitySnap -ID '171798691854' -Attach

      Attach the snapshot with ID '171798691854' so hosts can access it.'
      .EXAMPLE
      Set-UnitySnap -ID '171798691854' -Dettach

      Detach the snapshot with ID '171798691854' so hosts can no longer access it.
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High',DefaultParameterSetName="Set")]
  Param (
    #Default Parameters
    [Parameter(Mandatory = $false,ParameterSetName="Set",HelpMessage = 'EMC Unity Session')]
    [Parameter(Mandatory = $false,ParameterSetName="Copy",HelpMessage = 'EMC Unity Session')]
    [Parameter(Mandatory = $false,ParameterSetName="Restore",HelpMessage = 'EMC Unity Session')]
    [Parameter(Mandatory = $false,ParameterSetName="Attach",HelpMessage = 'EMC Unity Session')]
    [Parameter(Mandatory = $false,ParameterSetName="Detach",HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    
    #ID
    [Parameter(Mandatory = $true,Position = 0,ParameterSetName="Set",ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Snapshot ID or Object.')]
    [Parameter(Mandatory = $true,Position = 0,ParameterSetName="Copy",ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Snapshot ID or Object.')]
    [Parameter(Mandatory = $true,Position = 0,ParameterSetName="Restore",ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Snapshot ID or Object.')]
    [Parameter(Mandatory = $true,Position = 0,ParameterSetName="Attach",ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Snapshot ID or Object.')]
    [Parameter(Mandatory = $true,Position = 0,ParameterSetName="Detach",ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Snapshot ID or Object.')]
    [String[]]$ID,

    # Set
    [Parameter(Mandatory = $false,ParameterSetName="Set",HelpMessage = 'Snapshot name (Applies to block type storage resource snaps only. Filesystem snapshot names cannot be modified).')]
    [String[]]$name,
    [Parameter(Mandatory = $false,ParameterSetName="Set",HelpMessage = 'Snapshot description.')]
    [String]$Description,
    [Parameter(Mandatory = $false,ParameterSetName="Set",HelpMessage = 'Auto delete policy for  snapshot')]
    [bool]$isAutoDelete,
    [Parameter(Mandatory = $false,ParameterSetName="Set",HelpMessage = 'How long to keep the snapshot (Can be specified only if auto delete is set to false).')]
    [uint64]$retentionDuration,
    [Parameter(Mandatory = $false,ParameterSetName="Set",HelpMessage = 'The IO limit policy that is applied to this snapshot. This is only applicable to attached snapshots.')]
    [String]$ioLimitParameters,

    # Copy
    [Parameter(Mandatory = $true,ParameterSetName="Copy",HelpMessage = 'Copy a snapshot.')]
    [switch]$copy,
    [Parameter(Mandatory = $false,ParameterSetName="Copy",HelpMessage = 'Number of snapshot copies to make.')]
    [Uint32]$numCopies,
    [Parameter(Mandatory = $false,ParameterSetName="Copy",HelpMessage = 'Starting number for the group of copies.')]
    [Uint32]$copyStartNum,

    # Restore
    [Parameter(Mandatory = $true,ParameterSetName="Restore",HelpMessage = 'Restore the snapshot to the associated storage resource. ')]
    [switch]$restore,

    # Attach
    [Parameter(Mandatory = $true,ParameterSetName="Attach",HelpMessage = 'Attach the snapshot so hosts can access it.')]
    [switch]$attach,

    # Detach
    [Parameter(Mandatory = $true,ParameterSetName="Detach",HelpMessage = 'Detach the snapshot so hosts can no longer access it.')]
    [switch]$detach,

    # Copy, Restore & Attach
    [Parameter(Mandatory = $false,ParameterSetName="Copy",HelpMessage = 'Base name for the new snapshot copies.')]
    [Parameter(Mandatory = $false,ParameterSetName="Restore",HelpMessage = 'Name of the backup snapshot created before the restore operation occurs.')]
    [Parameter(Mandatory = $false,ParameterSetName="Attach",HelpMessage = 'Name of the backup snapshot created before the attach operation occurs.')]
    [String]$copyName
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"

    # Variables
    Switch ($PsCmdlet.ParameterSetName) {
      'Set' {
        $URI = '/api/instances/snap/<id>/action/modify'
        $StatusCode = 204
      }
      'Copy' {
        $URI = '/api/instances/snap/<id>/action/copy'
        $StatusCode = 200
      }
      'Restore' {
        $URI = '/api/instances/snap/<id>/action/restore'
        $StatusCode = 200
      }
      'Attach' {
        $URI = '/api/instances/snap/<id>/action/attach'
        $StatusCode = 200
      }
      'Detach' {
        $URI = '/api/instances/snap/<id>/action/detach'
        $StatusCode = 204
      }
    }
    
    $Type = 'snapshot'
    $TypeName = 'UnitySnap'
  }

  Process {

    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If ($Sess.TestConnection()) {

        Foreach ($i in $ID) {

          #Snap ID are normally integers. Convert it to strings 
          If (($i.GetType().Name) -Like "*Int*") {
            $i = $i.ToString()
          }

          # Determine input and convert to object if necessary
          Switch ($i.GetType().Name)
          {
            "String" {
              $Object = get-UnitySnap -Session $Sess -ID $i
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
              If ($Object = Get-UnitySnap -Session $Sess -ID $ObjectID) {
                If ($Object.Name) {
                  $ObjectName = $Object.Name
                } else {
                  $ObjectName = $ObjectID
                }          
              }
            }
          }

          If ($ObjectID) {

            #### REQUEST BODY

            # Creation of the body hash
            $body = @{}

            Switch ($PsCmdlet.ParameterSetName) {
              'Set' {
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

                If ($PSBoundParameters.ContainsKey('ioLimitParameters')) {
                      $body["ioLimitParameters"] = @{}
                      $ioLimit = @{}
                      $ioLimit['id'] = $ioLimitParameters
                      $body["ioLimitParameters"] = $ioLimit
                }
              }
              'Copy' {
                If ($PSBoundParameters.ContainsKey('copyName')) {
                      $body["copyName"] = $copyName
                }

                If ($PSBoundParameters.ContainsKey('numCopies')) {
                      $body["numCopies"] = $numCopies
                }

                If ($PSBoundParameters.ContainsKey('copyStartNum')) {
                      $body["copyStartNum"] = $copyStartNum
                }
              }
              'Restore' {
                If ($PSBoundParameters.ContainsKey('copyName')) {
                      $body["copyName"] = $copyName
                }
              }
              'Attach' {
                If ($PSBoundParameters.ContainsKey('copyName')) {
                  $body["copyName"] = $copyName
                }
              }
              'Detach' {}
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
            If ($pscmdlet.ShouldProcess($Sess.Name,"Modify $Type $ObjectName")) {
              $request = Send-UnityRequest -uri $URL -Session $Sess -Method 'POST' -Body $Body
            }
            
            If ($request.StatusCode -eq $StatusCode) {

              Write-Verbose "$Type with ID $ObjectID has been modified"

              Get-UnitySnap  -Session $Sess -ID $ObjectID

            }  # End If ($request.StatusCode -eq $StatusCode)
          } else {
            Write-Warning -Message "$Type with ID $i does not exist on the array $($sess.Name)"
          } # End If ($ObjectID)
        } # End Foreach ($i in $ID)
      } # End If ($Sess.TestConnection()) 
    } # End Foreach ($sess in $session)
  } # End Process
} # End Function

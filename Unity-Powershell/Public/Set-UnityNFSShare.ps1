Function Set-UnityNFSShare {

  <#
      .SYNOPSIS
      Modifies NFS share.
      .DESCRIPTION
      Modifies NFS share.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specify an UnitySession Object.
      .PARAMETER ID
      ID of the NFS share.
      .PARAMETER description
      NFS share description
      .PARAMETER isReadOnly
       Indicates whether the NFS share is read-only. Values are:
      - true - NFS share is read-only.
      - false - NFS share is read-write.
      .PARAMETER defaultAccess
      Default access level for all hosts accessing the NFS share.
      .PARAMETER minSecurity
      Minimal security level that must be provided by a client to mount the NFS share.
      .PARAMETER noAccessHosts
      Hosts with no access to the NFS share or its snapshots, as defined by the host resource type.
      .PARAMETER readOnlyHosts
      Hosts with read-only access to the NFS share and its snapshots, as defined by the host resource type.
      .PARAMETER readWriteHosts
      Hosts with read-write access to the NFS share and its snapshots, as defined by the host resource type.
      .PARAMETER rootAccessHosts
      Hosts with root access to the NFS share and its snapshots, as defined by the host resource type.
      .PARAMETER Append
      Append Hosts access to existing configuration
      .EXAMPLE
      Set-UnityNFSShare -id 'NFSShare_2' -rootAccessHosts Host_20 -append

      Set NFS Share with id 'NFSShare_2'
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    #Default Parameters
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),

    #NFSShareModify
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'ID of the NFS share')]
    [Object[]]$ID,

    #$nfsShareParameters
    [Parameter(Mandatory = $false,HelpMessage = 'NFS share description.')]
    [String]$description,
    [Parameter(Mandatory = $false,HelpMessage = 'Indicates whether the NFS share is read-only.')]
    [bool]$isReadOnly = $false,
    [Parameter(Mandatory = $false,HelpMessage = 'Default access level for all hosts accessing the NFS share.')]
    [NFSShareDefaultAccessEnum]$defaultAccess,
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
    [Parameter(Mandatory = $false,HelpMessage = 'Append Hosts access to existing configuration')]
    [Switch]$append
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    # Variables
    $URI = '/api/instances/storageResource/<id>/action/modifyFilesystem'
    $Type = 'NFS Share'
    $TypeName = 'UnityNFSShare'
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

            $UnitystorageResource = Get-UnityStorageResource -Session $sess | Where-Object {($_.filesystem.id -like $Object.Filesystem.id)}

            #### REQUEST BODY 

            # Creation of the body hash
            $body = @{}

            $body["nfsShareModify"] = @()
                
              #$NFSShareParameters
              $nfsShareModifyParameters = @{}

              $NFSShareModifyParameters["nfsShare"] = @{}
                  $NFSShare = @{}
                  $NFSShare['id'] = $ObjectID
              $NFSShareModifyParameters["nfsShare"] = $NFSShare
              
              #$nfsShareParameters
              $nfsShareModifyParameters["nfsShareParameters"] = @{}
                
                $nfsShareParameters = @{}

                If ($PSBoundParameters.ContainsKey('description')) {
                  $nfsShareParameters["description"] = "$($description)"
                }

                $nfsShareParameters["isReadOnly"] = $isReadOnly

                If ($PSBoundParameters.ContainsKey('defaultAccess')) {
                  $nfsShareParameters["defaultAccess"] = $defaultAccess
                }

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

                  If ($append) {
                    foreach ($h in $Object.noAccessHosts) {
                      $nfsShareParameters["noAccessHosts"] += $h
                    }
                  } 
                }

                If ($PSBoundParameters.ContainsKey('readOnlyHosts')) {
                
                  $nfsShareParameters["readOnlyHosts"] = @()

                  foreach ($h in $readOnlyHosts) {

                        $HostParam = @{}
                        $HostParam['id'] = $h

                    $nfsShareParameters["readOnlyHosts"] += $HostParam
                  }
            
                  If ($append) {
                    foreach ($h in $Object.readOnlyHosts) {
                      $nfsShareParameters["readOnlyHosts"] += $h
                    }
                  } 
                }

                If ($PSBoundParameters.ContainsKey('readWriteHosts')) {
                
                  $nfsShareParameters["readWriteHosts"] = @()

                  foreach ($h in $readWriteHosts) {

                        $HostParam = @{}
                        $HostParam['id'] = $h

                    $nfsShareParameters["readWriteHosts"] += $HostParam
                  }
            
                  If ($append) {
                    foreach ($h in $Object.readWriteHosts) {
                      $nfsShareParameters["readWriteHosts"] += $h
                    }
                  } 
                }

                If ($PSBoundParameters.ContainsKey('rootAccessHosts')) {
                
                  $nfsShareParameters["rootAccessHosts"] = @()

                  foreach ($h in $rootAccessHosts) {

                        $HostParam = @{}
                        $HostParam['id'] = $h

                    $nfsShareParameters["rootAccessHosts"] += $HostParam
                  }
            
                  If ($append) {
                    foreach ($h in $Object.rootAccessHosts) {
                      $nfsShareParameters["rootAccessHosts"] += $h
                    }
                  } 
                }

              $nfsShareModifyParameters["nfsShareParameters"] = $nfsShareParameters


            $body["nfsShareModify"] += $nfsShareModifyParameters

            If (-not $append) {
              Write-Warning -Message 'The existing host access parameters will be overwritten by the new settings. It could result to data unavailibility. Use the -Append parameter to add the new settings to the existing configuration.'
            }
              
            ####### END BODY - Do not edit beyond this line

            #Show $body in verbose message
            $Json = $body | ConvertTo-Json -Depth 10
            Write-Verbose $Json 

            #Building the URL
            $FinalURI = $URI -replace '<id>',$UnitystorageResource.id

            $URL = 'https://'+$sess.Server+$FinalURI
            Write-Verbose "URL: $URL"

            #Sending the request
            If ($pscmdlet.ShouldProcess($Sess.Name,"Modify $Type $ObjectName")) {
              $request = Send-UnityRequest -uri $URL -Session $Sess -Method 'POST' -Body $Body
            }
            
            If ($request.StatusCode -eq $StatusCode) {

              Write-Verbose "$Type with ID $ObjectID has been modified"

              Get-UnityNFSShare -Session $Sess -ID $ObjectID

            }  # End If ($request.StatusCode -eq $StatusCode)
          } else {
            Write-Warning -Message "$Type with ID $i does not exist on the array $($sess.Name)"
          } # End If ($ObjectID)
        } # End Foreach ($i in $ID)
      } # End If ($Sess.TestConnection()) 
    } # End Foreach ($sess in $session)
  } # End Process
} # End Function

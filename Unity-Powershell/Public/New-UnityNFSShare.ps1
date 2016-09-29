Function New-UnityNFSShare {

  <#
      .SYNOPSIS
      Creates NFS share.
      .DESCRIPTION
      Creates NFS share.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specify an UnitySession Object.
      .PARAMETER Filesystem
      Specify Filesystem ID
      .PARAMETER Path
      Local path to a location within a file system.
      .PARAMETER Name
      Name of the NFS share unique to NAS server
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
      .PARAMETER rootAccessHosts
      Hosts with read-write access to the NFS share and its snapshots, as defined by the host resource type.
      .PARAMETER rootAccessHosts
      Hosts with root access to the NFS share and its snapshots, as defined by the host resource type.
      .EXAMPLE
      New-UnityNFSShare -Filesystem fs_17 -Path / -Name 'NFSSHARE01' -rootAccessHosts Host_20

      Create a new NFS Share named 'NFSSHARE01'
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    #Default Parameters
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    
    #SetFilesystem
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Filesystem ID')]
    [String[]]$Filesystem,

    #nfsShareCreate
    [Parameter(Mandatory = $true,HelpMessage = 'Local path to a location within a file system')]
    [String]$Path,
    [Parameter(Mandatory = $true,HelpMessage = 'Name of the NFS share unique to NAS server')]
    [String]$Name,

    #$nfsShareParameters
    [Parameter(Mandatory = $false,HelpMessage = 'NFS share description')]
    [String]$description,
    [Parameter(Mandatory = $false,HelpMessage = 'Indicates whether the NFS share is read-only')]
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
    [string[]]$rootAccessHosts
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"

    ## Variables
    $URI = '/api/instances/storageResource/<id>/action/modifyFilesystem'
    $Type = 'Share NFS'
    $TypeName = 'UnityFilesystem'
    $StatusCode = 204
  }

  Process {

    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If ($Sess.TestConnection()) {

        Foreach ($fs in $Filesystem) {

          # Determine input and convert to UnityFilesystem object
          Switch ($fs.GetType().Name)
          {
            "String" {
              $Object = get-UnityFilesystem -Session $Sess -ID $fs
              $ObjectID = $Object.id
              If ($Object.Name) {
                $ObjectName = $Object.Name
              } else {
                $ObjectName = $ObjectID
              }
            }
            "$TypeName" {
              Write-Verbose "Input object type is $($i.GetType().Name)"
              $ObjectID = $fs.id
              If ($Object = Get-UnityFilesystem -Session $Sess -ID $ObjectID) {
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

            $UnityStorageRessource = Get-UnitystorageResource -Session $sess | ? {($_.Name -like $ObjectName) -and ($_.filesystem.id -like $ObjectID)}

            # Creation of the body hash
            $body = @{}

            $body["nfsShareCreate"] = @()

              $nfsShareCreateParameters = @{}

              # path
              $nfsShareCreateParameters["path"] = "$($path)"

              # name
              $nfsShareCreateParameters["name"] = "$($name)"
              
              #$nfsShareParameters
              $nfsShareCreateParameters["nfsShareParameters"] = @{}
                
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

                  foreach ($h in $readWriteHosts) {

                        $HostParam = @{}
                        $HostParam['id'] = $h

                    $nfsShareParameters["noAccessHosts"] += $HostParam
                  }
            
                }

                If ($PSBoundParameters.ContainsKey('readOnlyHosts')) {
                
                  $nfsShareParameters["readOnlyHosts"] = @()

                  foreach ($h in $readWriteHosts) {

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

              $nfsShareCreateParameters["nfsShareParameters"] = $nfsShareParameters

            $body["nfsShareCreate"] += $nfsShareCreateParameters

            ####### END BODY - Do not edit beyond this line

            #Show $body in verbose message
            $Json = $body | ConvertTo-Json -Depth 10
            Write-Verbose $Json 

            #Building the URL
            $URI = $URI -replace '<id>',$UnityStorageRessource.id

            $URL = 'https://'+$sess.Server+$URI
            Write-Verbose "URL: $URL"

            #Sending the request
            If ($pscmdlet.ShouldProcess($Sess.Name,"Create $Type $name")) {
              $request = Send-UnityRequest -uri $URL -Session $Sess -Method 'POST' -Body $Body
            }

            If ($request.StatusCode -eq $StatusCode) {

              Write-Verbose "$Type with ID $ObjectID has been modified"

              Get-UnityNFSShare -Session $Sess -Name $name

            } # End If ($request.StatusCode -eq $StatusCode)
          } else {
            Write-Warning -Message "$Type with ID $i does not exist on the array $($sess.Name)"
          } # End If ($ObjectID)
        } # End Foreach ($fs in $Filesystem)
      } # End If ($Sess.TestConnection()) 
    } # End Foreach ($sess in $session)
  } # End Process
} # End Function

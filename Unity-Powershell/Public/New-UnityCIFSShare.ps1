Function New-UnityCIFSShare {

  <#
      .SYNOPSIS
      Creates CIFS share.
      .DESCRIPTION
      Creates CIFS share.
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
      Name of the CIFS share unique to NAS server
      .PARAMETER cifsServer
      CIFS server ID to use for CIFS share creation, as defined by the cifsServer type
      .PARAMETER description
      CIFS share description
      .PARAMETER isReadOnly
      Indicates whether the CIFS share is read-only
      .PARAMETER isEncryptionEnabled
      Indicates whether CIFS encryption for Server Message Block (SMB) 3.0 is enabled for the CIFS share
      .PARAMETER isContinuousAvailabilityEnabled
      Indicates whether continuous availability for SMB 3.0 is enabled for the CIFS share
      .PARAMETER isABEEnabled
      Enumerate file with read access and directories with list access in folder listings
      .PARAMETER isBranchCacheEnabled
      Branch Cache optimizes traffic between the NAS server and Branch Office Servers
      .PARAMETER offlineAvailability
      Offline Files store a version of the shared resources on the client computer in the file system cache, a reserved portion of disk space, which the client computer can access even when it is disconnected from the network
      .PARAMETER umask
      The default UNIX umask for new files created on the share
      .EXAMPLE
      New-UnityCIFSShare -Filesystem 'fs_1' -Name 'SHARE01' -path '/' -cifsServer 'cifs_1'

      Create a new CIFS Share named 'SHARE01'
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    #Default Parameters
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    
    #SetFilesystem
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Filesystem ID')]
    [String[]]$Filesystem,

    #cifsShareCreate
    [Parameter(Mandatory = $true,HelpMessage = 'Local path to a location within a file system')]
    [String]$Path,
    [Parameter(Mandatory = $true,HelpMessage = 'Name of the CIFS share unique to NAS server')]
    [String]$Name,
    [Parameter(Mandatory = $true,HelpMessage = 'CIFS server ID to use for CIFS share creation, as defined by the cifsServer type')]
    [String]$cifsServer,

    #$cifsShareParameters
    [Parameter(Mandatory = $false,HelpMessage = 'CIFS share description')]
    [String]$description,
    [Parameter(Mandatory = $false,HelpMessage = 'Indicates whether the CIFS share is read-only')]
    [bool]$isReadOnly,
    [Parameter(Mandatory = $false,HelpMessage = 'Indicates whether CIFS encryption for Server Message Block (SMB) 3.0 is enabled for the CIFS share')]
    [bool]$isEncryptionEnabled,
    [Parameter(Mandatory = $false,HelpMessage = 'Indicates whether continuous availability for SMB 3.0 is enabled for the CIFS share')]
    [bool]$isContinuousAvailabilityEnabled,
    [Parameter(Mandatory = $false,HelpMessage = 'Enumerate file with read access and directories with list access in folder listings')]
    [bool]$isABEEnabled,
    [Parameter(Mandatory = $false,HelpMessage = 'Branch Cache optimizes traffic between the NAS server and Branch Office Servers')]
    [bool]$isBranchCacheEnabled,
    [Parameter(Mandatory = $false,HelpMessage = 'Offline Files store a version of the shared resources on the client computer in the file system cache, a reserved portion of disk space, which the client computer can access even when it is disconnected from the network')]
    [CifsShareOfflineAvailabilityEnum]$offlineAvailability,
    [Parameter(Mandatory = $false,HelpMessage = 'The default UNIX umask for new files created on the share')]
    [String]$umask
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"

    ## Variables
    $URI = '/api/instances/storageResource/<id>/action/modifyFilesystem'
    $Type = 'Share CIFS'
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

            $body["cifsShareCreate"] = @()

              $cifsShareCreateParameters = @{}

              # path
              $cifsShareCreateParameters["path"] = "$($path)"

              # name
              $cifsShareCreateParameters["name"] = "$($name)"

              # cifsServer
              $cifsShareCreateParameters["cifsServer"] = @{}
                $cifsServerParameters = @{}
                $cifsServerParameters['id'] = "$($cifsServer)"
              $cifsShareCreateParameters["cifsServer"] = $cifsServerParameters
              
              #$cifsShareParameters
              If (($PSBoundParameters.ContainsKey('description')) -or ($PSBoundParameters.ContainsKey('isReadOnly')) -or ($PSBoundParameters.ContainsKey('isEncryptionEnabled')) -or ($PSBoundParameters.ContainsKey('isContinuousAvailabilityEnabled')) -or ($PSBoundParameters.ContainsKey('isABEEnabled')) -or ($PSBoundParameters.ContainsKey('isBranchCacheEnabled')) -or ($PSBoundParameters.ContainsKey('offlineAvailability')) -or ($PSBoundParameters.ContainsKey('umask'))){
                $cifsShareCreateParameters["cifsShareParameters"] = @{}
                
                $cifsShareParameters = @{}

                If ($PSBoundParameters.ContainsKey('description')) {
                  $cifsShareParameters["description"] = "$($description)"
                }

                If ($PSBoundParameters.ContainsKey('isReadOnly')) {
                  $cifsShareParameters["isReadOnly"] = $isReadOnly
                }

                If ($PSBoundParameters.ContainsKey('isEncryptionEnabled')) {
                  $cifsShareParameters["isEncryptionEnabled"] = $isEncryptionEnabled
                }

                If ($PSBoundParameters.ContainsKey('isContinuousAvailabilityEnabled')) {
                  $cifsShareParameters["isContinuousAvailabilityEnabled"] = $isContinuousAvailabilityEnabled
                }

                If ($PSBoundParameters.ContainsKey('isABEEnabled')) {
                  $cifsShareParameters["isABEEnabled"] = $isABEEnabled
                }

                If ($PSBoundParameters.ContainsKey('isBranchCacheEnabled')) {
                  $cifsShareParameters["isBranchCacheEnabled"] = $isBranchCacheEnabled
                }

                If ($PSBoundParameters.ContainsKey('offlineAvailability')) {
                  $cifsShareParameters["offlineAvailability"] = "$($offlineAvailability)"
                }

                If ($PSBoundParameters.ContainsKey('umask')) {
                  $cifsShareParameters["umask"] = "$($umask)"
                }

              $cifsShareCreateParameters["cifsShareParameters"] = $cifsShareParameters

              }

            $body["cifsShareCreate"] += $cifsShareCreateParameters

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

              Get-UnityCIFSShare -Session $Sess -Name $name

            } # End If ($request.StatusCode -eq $StatusCode)
          } else {
            Write-Warning -Message "$Type with ID $i does not exist on the array $($sess.Name)"
          } # End If ($ObjectID)
        } # End Foreach ($fs in $Filesystem)
      } # End If ($Sess.TestConnection()) 
    } # End Foreach ($sess in $session)
  } # End Process
} # End Function

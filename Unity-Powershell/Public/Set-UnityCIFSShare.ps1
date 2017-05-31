Function Set-UnityCIFSShare {

  <#
      .SYNOPSIS
      Modifies CIFS share.
      .DESCRIPTION
      Modifies CIFS share.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specify an UnitySession Object.
      .PARAMETER ID
      ID of the CIFS share.
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
      Offline Files store a version of the shared resources on the client computer in the file system cache, 
      a reserved portion of disk space, which the client computer can access even when it is disconnected from the network.
      .PARAMETER umask
      The default UNIX umask for new files created on the share.
      .PARAMETER Confirm
      If the value is $true, indicates that the cmdlet asks for confirmation before running. 
      If the value is $false, the cmdlet runs without asking for user confirmation.
      .PARAMETER WhatIf
      Indicate that the cmdlet is run only to display the changes that would be made and actually no objects are modified.
      .EXAMPLE
      Set-UnityCIFSShare -ID 'SMBShare_1' -Description 'New description'

      Modifies the CIFS share with id 'SMBShare_1'
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    #Default Parameters
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),

    #cifsShareModify
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'ID of the CIFS share')]
    [Object[]]$ID,

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
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    # Variables
    $URI = '/api/instances/storageResource/<id>/action/modifyFilesystem'
    $Type = 'CIFS Share'
    $TypeName = 'UnityCIFSShare'
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

            $UnitystorageResource = Get-UnitystorageResource -Session $sess | Where-Object {($_.filesystem.id -like $Object.Filesystem.id)}

            #### REQUEST BODY 

            # Creation of the body hash
            $body = @{}

            $body["cifsShareModify"] = @()

              $cifsShareModifyParameters = @{}
                $cifsShareModifyParameters["cifsShare"] = @{}
                  $cifsShare = @{}
                  $cifsShare['id'] = $ObjectID
                $cifsShareModifyParameters["cifsShare"] = $cifsShare

              #$cifsShareParameters
              If (($PSBoundParameters.ContainsKey('description')) -or ($PSBoundParameters.ContainsKey('isReadOnly')) -or ($PSBoundParameters.ContainsKey('isEncryptionEnabled')) -or ($PSBoundParameters.ContainsKey('isContinuousAvailabilityEnabled')) -or ($PSBoundParameters.ContainsKey('isABEEnabled')) -or ($PSBoundParameters.ContainsKey('isBranchCacheEnabled')) -or ($PSBoundParameters.ContainsKey('offlineAvailability')) -or ($PSBoundParameters.ContainsKey('umask'))){
                $cifsShareModifyParameters["cifsShareParameters"] = @{}
                
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

              $cifsShareModifyParameters["cifsShareParameters"] = $cifsShareParameters

              }

            $body["cifsShareModify"] += $cifsShareModifyParameters

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

              Get-UnityCIFSShare -Session $Sess -ID $ObjectID

            }  # End If ($request.StatusCode -eq $StatusCode)
          } else {
            Write-Warning -Message "$Type with ID $i does not exist on the array $($sess.Name)"
          } # End If ($ObjectID)
        } # End Foreach ($i in $ID)
      } # End If ($Sess.TestConnection()) 
    } # End Foreach ($sess in $session)
  } # End Process
} # End Function

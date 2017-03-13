Function New-UnitySnap {

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
      .PARAMETER storageRessouce
      Storage resource ID or object.
      .PARAMETER Name
      Name for the new snapshot.
      .PARAMETER Description
      Description for new snapshot.
      .PARAMETER isAutoDelete
      Auto delete policy for new snapshot.
      .PARAMETER retentionDuration
      How long (in seconds) to keep the snapshot (Can be specified only if auto delete is set to false).
      .PARAMETER isReadOnly
      Indicates if the new snapshot should be read-only.
      .PARAMETER filesystemAccessType
      Indicates if the new snapshot should be created with checkpoint or protocol type access (file system or VMware NFS datastore snapshots only).
      .PARAMETER Confirm
      If the value is $true, indicates that the cmdlet asks for confirmation before running. If the value is $false, the cmdlet runs without asking for user confirmation.
      .PARAMETER WhatIf
      Indicate that the cmdlet is run only to display the changes that would be made and actually no objects are modified.
      .EXAMPLE
      New-UnitySnap -StorageResource 'res_41' -Name 'snap01'

      Create snap named 'snap01' from sorage resource ID 'res_41'
      .EXAMPLE
      Get-UnityVMwareNFS -Name 'VOLUME01' | New-UnitySnap

      Create a snapshot of the VMware NFS volume.
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    #Default Parameters
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    
    #UnitySnap
    [Parameter(Mandatory = $true,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Storage resource ID or object.')]
    [Object[]]$storageResource,
    [Parameter(Mandatory = $false,HelpMessage = 'Name for the new snapshot')]
    [String]$name,
    [Parameter(Mandatory = $false,HelpMessage = 'Description for new snapshot')]
    [String]$Description,
    [Parameter(Mandatory = $false,HelpMessage = 'Auto delete policy for new snapshot')]
    [bool]$isAutoDelete,
    [Parameter(Mandatory = $false,HelpMessage = 'How long to keep the snapshot (Can be specified only if auto delete is set to false).')]
    [uint64]$retentionDuration,
    [Parameter(Mandatory = $false,HelpMessage = 'Indicates if the new snapshot should be read-only.')]
    [bool]$isReadOnly,
    [Parameter(Mandatory = $false,HelpMessage = 'Indicates if the new snapshot should be created with checkpoint or protocol type access (file system or VMware NFS datastore snapshots only)')]
    [FilesystemSnapAccessTypeEnum]$filesystemAccessType
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    ## Variables
    $URI = '/api/types/snap/instances'
    $Type = 'snap'
    $StatusCode = 201
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      Foreach ($sr in $storageResource) {

        # Determine input and convert to object if necessary

        Write-Verbose "Input object type is $($sr.GetType().Name)"
        Switch ($sr.GetType().Name)
        {
          "UnityFilesystem" {
            $ObjectID = $sr.StorageResource.id
          }

          "UnityLUN" {
            $ObjectID = $sr.StorageResource.id
          }

          "String" {
            If ($Object = Get-UnitystorageResource -Session $Sess -ID $sr -ErrorAction SilentlyContinue) {
              $ObjectID = $Object.id
            } else {
              Throw "This Storage Resource does not exist"
            }
          }
        }

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

            Get-UnitySnap -Session $Sess -ID $results.id
          } # End If ($request.StatusCode -eq $StatusCode)
        } # End If ($Sess.TestConnection()) 
      } # End Foreach
    } # End Foreach ($sess in $session)
  } # End Process
} # End Function
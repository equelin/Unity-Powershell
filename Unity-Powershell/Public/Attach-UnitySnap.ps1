Function Attach-UnitySnap {

  <#
      .SYNOPSIS
      Attach the snapshot so hosts can access it.
      .DESCRIPTION
      Attach the snapshot so hosts can access it. 
      Attaching a snapshot makes the snapshot accessible to configured hosts for restoring files and data.
      Attaching a snapshot is only applicable for block snapshots, and makes the snapshot available for host IO. 
      A host must have Snapshot access or LUN and Snapshot access configured in order to access the snapshot. 
      When a snapshot is attached, a copy of the snapshot is created in case the administrator wants to preserve the current snapshot view for future use. 
      If needed, the copy can be used later to discard the changes made to the snapshot while it was attached. 
      Similarly, an attached snapshot can be detached in order to remove host access to the snapshot. 
      Only a single snapshot per LUN can be attached at any given time, and must be detached prior to attaching another snapshot of the same LUN.
      The host must have access to protection data in order to access the snapshot.  
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specify an UnitySession Object.
      .PARAMETER ID
      Snapshot ID or Object.
      .PARAMETER copyName
      Name of the backup snapshot created before the Attach operation occurs.
      .PARAMETER Confirm
      If the value is $true, indicates that the cmdlet asks for confirmation before running. If the value is $false, the cmdlet runs without asking for user confirmation.
      .PARAMETER WhatIf
      Indicate that the cmdlet is run only to display the changes that would be made and actually no objects are modified.
      .EXAMPLE
      Attach-UnitySnap -ID '171798691854'

      Attach the snapshot with ID '171798691854'.
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    #Default Parameters
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    [UnitySession[]]$session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    
    #UnitySnap
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Snapshot ID or Object.')]
    [Object[]]$ID,
    [Parameter(Mandatory = $false,HelpMessage = 'Name of the backup snapshot created before the Attach operation occurs.')]
    [String]$copyName
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"

    # Variables
    $URI = '/api/instances/snap/<id>/action/attach'
    $Type = 'snapshot'
    $TypeName = 'UnitySnap'
    $StatusCode = 200
  }

  Process {

    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If ($Sess.TestConnection()) {

        Foreach ($i in $ID) {

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

            If ($PSBoundParameters.ContainsKey('copyName')) {
                  $body["copyName"] = $copyName
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
            If ($pscmdlet.ShouldProcess($Sess.Name,"Attach $Type $ObjectName")) {
              $request = Send-UnityRequest -uri $URL -Session $Sess -Method 'POST' -Body $Body
            }
            
            If ($request.StatusCode -eq $StatusCode) {

              #Formating the result. Converting it from JSON to a Powershell object
              $results = ($request.content | ConvertFrom-Json).content

              Write-Verbose "$Type with ID $ObjectID has been Attachd"

              Get-UnitySnap  -Session $Sess -ID $results.copy.id

            }  # End If ($request.StatusCode -eq $StatusCode)
          } else {
            Write-Warning -Message "$Type with ID $i does not exist on the array $($sess.Name)"
          } # End If ($ObjectID)
        } # End Foreach ($i in $ID)
      } # End If ($Sess.TestConnection()) 
    } # End Foreach ($sess in $session)
  } # End Process
} # End Function

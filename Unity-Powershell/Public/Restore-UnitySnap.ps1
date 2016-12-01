Function Restore-UnitySnap {

  <#
      .SYNOPSIS
      Restore the snapshot to the associated storage resource. 
      .DESCRIPTION
      Restore the snapshot to the associated storage resource.
      Before the restoration begins, the system creates a snapshot of the storage resource. You can use this snapshot to restore the storage resource to its previous state. 
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
      Name of the backup snapshot created before the Restore operation occurs.
      .PARAMETER Confirm
      If the value is $true, indicates that the cmdlet asks for confirmation before running. If the value is $false, the cmdlet runs without asking for user confirmation.
      .PARAMETER WhatIf
      Indicate that the cmdlet is run only to display the changes that would be made and actually no objects are modified.
      .EXAMPLE
      Restore-UnitySnap -ID '171798691854'

      Restore the snapshot with ID '171798691854' to the associated storage resource.
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    #Default Parameters
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    [UnitySession[]]$session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    
    #UnitySnap
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Snapshot ID or Object.')]
    [Object[]]$ID,
    [Parameter(Mandatory = $false,HelpMessage = 'Name of the backup snapshot created before the Restore operation occurs.')]
    [String]$copyName
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"

    # Variables
    $URI = '/api/instances/snap/<id>/action/restore'
    $Type = 'snapshot'
    $TypeName = 'UnitySnap'
    $StatusCode = 200
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
            If ($pscmdlet.ShouldProcess($Sess.Name,"Restore $Type $ObjectName")) {
              $request = Send-UnityRequest -uri $URL -Session $Sess -Method 'POST' -Body $Body
            }
            
            If ($request.StatusCode -eq $StatusCode) {

              #Formating the result. Converting it from JSON to a Powershell object
              $results = ($request.content | ConvertFrom-Json).content

              Write-Verbose "$Type with ID $ObjectID has been restored"

              Get-UnitySnap  -Session $Sess -ID $results.backup.id

            }  # End If ($request.StatusCode -eq $StatusCode)
          } else {
            Write-Warning -Message "$Type with ID $i does not exist on the array $($sess.Name)"
          } # End If ($ObjectID)
        } # End Foreach ($i in $ID)
      } # End If ($Sess.TestConnection()) 
    } # End Foreach ($sess in $session)
  } # End Process
} # End Function

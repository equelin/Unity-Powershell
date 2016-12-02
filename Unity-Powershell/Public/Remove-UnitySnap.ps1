Function Remove-UnitySnap {

  <#
      .SYNOPSIS
      Delete a snapshot.
      .DESCRIPTION
      Delete a snapshot.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specify an UnitySession Object.
      .PARAMETER ID
      ID of the snapshot or snapshot Object. ID need to be surounded by quote like this '171798691854'.
      .PARAMETER Confirm
      If the value is $true, indicates that the cmdlet asks for confirmation before running. 
      If the value is $false, the cmdlet runs without asking for user confirmation.
      .PARAMETER WhatIf
      Indicate that the cmdlet is run only to display the changes that would be made and actually no objects are modified.
      .EXAMPLE
      Remove-UnitySnap -ID '171798691854'

      Delete the snapshot with ID '171798691854'
      .EXAMPLE
      Get-UnitySnap | Remove-UnitySnap

      Delete all existing snapshots.
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    [UnitySession[]]$session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'snapshot ID or snapshot Object')]
    [Object[]]$ID
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"

    # Variables
    $URI = '/api/instances/snap/<id>'
    $Type = 'snapshot'
    $TypeName = 'UnitySnap'
    $StatusCode = 204
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
              $Object = Get-UnitySnap -Session $Sess -ID $i
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
          } # End Switch

          If ($ObjectID) {
            
            #Building the URL
            $FinalURI = $URI -replace '<id>',$ObjectID

            $URL = 'https://'+$sess.Server+$FinalURI
            Write-Verbose "URL: $URL"

            if ($pscmdlet.ShouldProcess($Sess.Name,"Delete $Type $ObjectName")) {
              #Sending the request
              $request = Send-UnityRequest -uri $URL -Session $Sess -Method 'DELETE'
            }

            If ($request.StatusCode -eq $StatusCode) {

              Write-Verbose "$Type with ID $ObjectID has been deleted"

            } # End If ($request.StatusCode -eq $StatusCode)
          } else {
            Write-Warning -Message "$Type with ID $i does not exist on the array $($sess.Name)"
          } # End If ($ObjectID)
        } # End Foreach ($i in $ID)
      } # End If ($Sess.TestConnection()) 
    } # End Foreach ($sess in $session)
  } # End Process
} # End Function

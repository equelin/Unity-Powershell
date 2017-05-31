Function Remove-UnityVMwareNFS {

  <#
      .SYNOPSIS
      Delete a filesystem.
      .DESCRIPTION
      Delete a filesystem.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specify an UnitySession Object.
      .PARAMETER ID
      Filesystem ID or Object.
      .PARAMETER Confirm
      If the value is $true, indicates that the cmdlet asks for confirmation before running. If the value is $false, the cmdlet runs without asking for user confirmation.
      .PARAMETER WhatIf
      Indicate that the cmdlet is run only to display the changes that would be made and actually no objects are modified.
      .EXAMPLE
      Remove-UnityVMwareNFS -ID 'fs_1'

      Delete the filesystem named 'fs_1'
      .EXAMPLE
      Get-UnityVMwareNFS -Name 'FS01' | Remove-UnityVMwareNFS

      Delete the filesystem named 'FS01'. The filesystem's informations are provided by the Get-UnityVMwareNFS through the pipeline.
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Filesystem ID or Object.')]
    $ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    # Variables
    $URI = '/api/instances/storageResource/<id>'
    $Type = 'VMware NFS LUN'
    $TypeName = 'UnityFilesystem'
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

            $UnityStorageResource = Get-UnitystorageResource -Session $sess | Where-Object {($_.Name -like $ObjectName) -and ($_.filesystem.id -like $ObjectID)}

            #Building the URL
            $FinalURI = $URI -replace '<id>',$UnityStorageResource.id

            $URL = 'https://'+$sess.Server+$FinalURI
            Write-Verbose "URL: $URL"

            if ($pscmdlet.ShouldProcess($Sess.Name,"Delete $Type $ObjectName")) {
              #Sending the request
              $request = Send-UnityRequest -uri $URL -Session $Sess -Method 'DELETE'
            }

            If ($request.StatusCode -eq $StatusCode) {

              Write-Verbose "$Type with ID: $ObjectID has been deleted"

            }
          } else {
            Write-Warning -Message "$Type with ID $i does not exist on the array $($sess.Name)"
          } # End If ($ObjectID)
        } # End Foreach ($i in $ID)
      } # End If ($Sess.TestConnection()) 
    } # End Foreach ($sess in $session)
  } # End Process
} # End Function

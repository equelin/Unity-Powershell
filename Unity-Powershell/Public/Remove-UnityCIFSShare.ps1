Function Remove-UnityCIFSShare {

  <#
      .SYNOPSIS
      Deletes CIFS share.
      .DESCRIPTION
      Deletes CIFS share.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specify an UnitySession Object.
      .PARAMETER ID
      CIFS Share ID or Object.
      .PARAMETER Confirm
      If the value is $true, indicates that the cmdlet asks for confirmation before running. If the value is $false, the cmdlet runs without asking for user confirmation.
      .PARAMETER WhatIf
      Indicate that the cmdlet is run only to display the changes that would be made and actually no objects are modified.      
      .EXAMPLE
      Remove-UnityCIFSShare -ID 'SMBShare_1'

      Delete the CIFS share with id 'SMBShare_1'
  #>

    [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    #Default Parameters
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),

    #cifsShareDelete
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'ID of the CIFS share')]
    $ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"
    
    # Variables
    $URI = '/api/instances/storageResource/<id>/action/modifyFilesystem'
    $Type = 'Share CIFS'
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

            $UnityStorageResource = Get-UnityStorageResource -Session $sess | Where-Object {($_.filesystem.id -like $Object.filesystem.id)}

            #### REQUEST BODY

            # Creation of the body hash
            $body = @{}

            $body["cifsShareDelete"] = @()

              $cifsShareDeleteParameters = @{}
                $cifsShareDeleteParameters["cifsShare"] = @{}
                  $cifsShareParameters = @{}
                  $cifsShareParameters['id'] = $ObjectID
                $cifsShareDeleteParameters["cifsShare"] = $cifsShareParameters

            $body["cifsShareDelete"] += $cifsShareDeleteParameters

            ####### END BODY - Do not edit beyond this line

            #Show $body in verbose message
            $Json = $body | ConvertTo-Json -Depth 10
            Write-Verbose $Json 

            #Building the URL
            $FinalURI = $URI -replace '<id>',$UnityStorageResource.id

            $URL = 'https://'+$sess.Server+$FinalURI
            Write-Verbose "URL: $URL"

            if ($pscmdlet.ShouldProcess($Sess.Name,"Delete $Type $ObjectName")) {
              #Sending the request
              $request = Send-UnityRequest -uri $URL -Session $Sess -Method 'POST' -Body $Body
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
  
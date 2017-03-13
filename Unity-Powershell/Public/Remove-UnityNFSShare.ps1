Function Remove-UnityNFSShare {

  <#
      .SYNOPSIS
      Deletes NFS share.
      .DESCRIPTION
      Deletes NFS share.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      SpeNFS an UnitySession Object.
      .PARAMETER Confirm
      If the value is $true, indicates that the cmdlet asks for confirmation before running. If the value is $false, the cmdlet runs without asking for user confirmation.
      .PARAMETER WhatIf
      Indicate that the cmdlet is run only to display the changes that would be made and actually no objects are modified.      
      .EXAMPLE
      Remove-UnityNFSShare -ID 'NFSShare_2'

      Delete the NFS share with id 'NFSShare_2'
  #>

    [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    #Default Parameters
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),

    #NFS Share ID or Object.
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'NFS Share ID or Object.')]
    $ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"
    
    # Variables
    $URI = '/api/instances/storageResource/<id>/action/modifyFilesystem'
    $Type = 'Share NFS'
    $TypeName = 'UnityNFSShare'
    $StatusCode = 204
  }

  Process {

    Foreach ($sess in $session) {

      Write-Debug -Message "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If ($Sess.TestConnection()) {

        Foreach ($i in $ID) {

          # Determine input and convert to object if necessary
          Switch ($i.GetType().Name)
          {
            "String" {
              $Object = get-UnityNFSShare -Session $Sess -ID $i
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
              If ($Object = Get-UnityNFSShare -Session $Sess -ID $ObjectID) {
                If ($Object.Name) {
                  $ObjectName = $Object.Name
                } else {
                  $ObjectName = $ObjectID
                }          
              }
            }
          } # End Switch

          If ($ObjectID) {

            $UnityStorageResource = Get-UnitystorageResource -Session $sess | Where-Object {($_.filesystem.id -like $Object.filesystem.id)}

            #### REQUEST BODY

            # Creation of the body hash
            $body = @{}

            $body["nfsShareDelete"] = @()

              $nfsShareDeleteParameters = @{}
                $nfsShareDeleteParameters["nfsShare"] = @{}
                  $nfsShareParameters = @{}
                  $nfsShareParameters['id'] = $ObjectID
                $nfsShareDeleteParameters["nfsShare"] = $nfsShareParameters

            $body["nfsShareDelete"] += $nfsShareDeleteParameters

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
  
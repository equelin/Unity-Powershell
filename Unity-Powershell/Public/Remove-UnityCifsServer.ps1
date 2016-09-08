Function Remove-UnityCIFSServer {

  <#
      .SYNOPSIS
      Delete a Cifs Server.
      .DESCRIPTION
      Delete a Cifs Server.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specify an UnitySession Object.
      .PARAMETER ID
      CIFS Server ID or Object.
      .PARAMETER skipUnjoin
      Keep SMB server account unjoined in Active Directory after deletion.
      .PARAMETER domainUsername
      Username for unjoin.
      .PARAMETER domainPassword
      Password for unjoin.
      .PARAMETER Confirm
      If the value is $true, indicates that the cmdlet asks for confirmation before running. If the value is $false, the cmdlet runs without asking for user confirmation.
      .PARAMETER WhatIf
      Indicate that the cmdlet is run only to display the changes that would be made and actually no objects are modified.
      .EXAMPLE
      Remove-UnityCifsServer -ID 'cifs_1'

      Delete the Cifs Server with ID 'cifs_1'
      .EXAMPLE
      Get-UnityCifsServer -Name 'CIFS01' | Remove-UnityCifsServer

      Delete the Cifs Server named 'CIFS01'. The Cifs Server's informations are provided by the Get-UnityNasServer through the pipeline.
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'CIFS Server ID or Object')]
    $ID,
    [Parameter(Mandatory = $false,HelpMessage = 'Keep SMB server account unjoined in Active Directory after deletion')]
    [bool]$skipUnjoin,
    [Parameter(Mandatory = $false,HelpMessage = 'Username for unjoin')]
    [String]$domainUsername,
    [Parameter(Mandatory = $false,HelpMessage = 'Password for unjoin')]
    [String]$domainPassword
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"

    # Variables
    $URI = '/api/instances/cifsServer/<id>'
    $Type = 'CIFS Server'
    $TypeName = 'UnityCifsServer'
    $StatusCode = 204
  }

  Process {

    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If ($Sess.TestConnection()) {

        Foreach ($i in $ID) {

          #### REQUEST BODY 

          # Creation of the body hash
          $body = @{}

          If ($PSBoundParameters.ContainsKey('skipUnjoin')) {
            $body["skipUnjoin"] = $skipUnjoin
          }

          If ($PSBoundParameters.ContainsKey('domainUsername')) {
            $body["domainUsername"] = "$domainUsername"
          }

          If ($PSBoundParameters.ContainsKey('domainPassword')) {
            $body["domainPassword"] = $domainPassword
          }

          ####### END BODY - Do not edit beyond this line

          #Show $body in verbose message
          $Json = $body | ConvertTo-Json -Depth 10
          Write-Verbose $Json  

          # Determine input and convert to object if necessary
          Switch ($i.GetType().Name)
          {
            "String" {
              $Object = get-UnityCIFSServer -Session $Sess -ID $i
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
              If ($Object = Get-UnityCIFSServer -Session $Sess -ID $ObjectID) {
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
            $URI = $URI -replace '<id>',$ObjectID

            $URL = 'https://'+$sess.Server+$URI
            Write-Verbose "URL: $URL"

            if ($pscmdlet.ShouldProcess($Sess.Name,"Delete $Type $ObjectName")) {
              #Sending the request
              $request = Send-UnityRequest -uri $URL -Session $Sess -Method 'DELETE' -Body $body
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

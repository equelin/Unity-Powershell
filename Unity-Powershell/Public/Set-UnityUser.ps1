Function Set-UnityUser {

  <#
      .SYNOPSIS
      Modifies local user parameters.
      .DESCRIPTION
      Modifies local user parameters.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specify an UnitySession Object.
      .PARAMETER Confirm
      If the value is $true, indicates that the cmdlet asks for confirmation before running. 
      If the value is $false, the cmdlet runs without asking for user confirmation.
      .PARAMETER WhatIf
      Indicate that the cmdlet is run only to display the changes that would be made and actually no objects are modified.
      .PARAMETER ID
      User ID or Object.
      .PARAMETER role
      User role. Might be:
      - administrator
      - storageadmin
      - vmadmin
      - operator
      .PARAMETER password
      Initial password for the user.
      .EXAMPLE
      Set-UnityUser -Name 'User' -Role 'operator'

      Gives the role 'operator' to the user 'User'
      .EXAMPLE
      Get-UnityUSer -Name 'User' | Set-UnityUser -Role 'operator'

      Gives the role 'operator' to the user 'User'. The user's information are provided by the Get-UnityUser through the pipeline.
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'User ID or Object')]
    [String[]]$ID,
    [Parameter(Mandatory = $false,HelpMessage = 'User role. It mights be administrator, storageadmin, vmadmin or operator')]
    [ValidateSet('administrator', 'storageadmin', 'vmadmin', 'operator')]
    [String]$Role,
    [Parameter(Mandatory = $false,HelpMessage = 'User Password')]
    [String]$newPassword,
    [Parameter(Mandatory = $false,HelpMessage = 'User Password')]
    [String]$oldPassword
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"

    # Variables
    $URI = '/api/instances/user/<id>/action/modify'
    $Type = 'User'
    $TypeName = 'UnityUser'
    $StatusCode = 204
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
              $Object = get-UnityUser -Session $Sess -ID $i
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
              If ($Object = Get-UnityUser -Session $Sess -ID $ObjectID) {
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

            # Role parameter
            $body["id"] = "$($ObjectID)"

            # role parameter
            If ($Role) {
              $body["role"] = "$($Role)"
            }

            # oldPassword parameter
            If ($password -and $oldPassword) {
              $body["oldPassword"] = "$($oldPassword)"
              $body["password"] = "$($newPassword)"
            }

            ####### END BODY - Do not edit beyond this line

            #Show $body in verbose message
            $Json = $body | ConvertTo-Json -Depth 10
            Write-Verbose $Json 

            #Building the URL
            $URI = $URI -replace '<id>',$ObjectID

            $URL = 'https://'+$sess.Server+$URI
            Write-Verbose "URL: $URL"

            #Sending the request
            If ($pscmdlet.ShouldProcess($Sess.Name,"Modify $Type $ObjectName")) {
              $request = Send-UnityRequest -uri $URL -Session $Sess -Method 'POST' -Body $Body
            }

            If ($request.StatusCode -eq $StatusCode) {

              Write-Verbose "$Type with ID $ObjectID has been modified"

              Get-UnityUser -Session $Sess -id $ObjectID

            }  # End If ($request.StatusCode -eq $StatusCode)
          } else {
            Write-Warning -Message "$Type with ID $i does not exist on the array $($sess.Name)"
          } # End If ($ObjectID)
        } # End Foreach ($i in $ID)
      } # End If ($Sess.TestConnection()) 
    } # End Foreach ($sess in $session)
  } # End Process
} # End Function

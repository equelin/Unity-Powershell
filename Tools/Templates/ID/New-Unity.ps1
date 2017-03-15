Function New-UnitySMTPServer { #########################################

  <#
      .SYNOPSIS
      Create a new SMTP server (Default or PhoneHome). #########################################
      .DESCRIPTION
      Create a new SMTP server (Default or PhoneHome). #########################################
      You need to have an active session with the array. 
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session #########################################
      Specify an UnitySession Object.
      .PARAMETER address #########################################
      IP address of the SMTP server.
      .PARAMETER type #########################################
      SMTP server type. Might be:
      - Default
      - PhoneHome
      .PARAMETER Confirm 
      If the value is $true, indicates that the cmdlet asks for confirmation before running. If the value is $false, the cmdlet runs without asking for user confirmation.
      .PARAMETER WhatIf
      Indicate that the cmdlet is run only to display the changes that would be made and actually no objects are modified.
      .EXAMPLE 
      New-UnitySMTPServer -address 'smtp.example.com' -type 'default' #########################################

      Create a new default SMTP server. #########################################
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $true,HelpMessage = 'IP address of the SMTP server.')]
    [string]$address,
    [Parameter(Mandatory = $true,HelpMessage = 'SMTP server type.')]
    [SmtpTypeEnum]$type
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    ## Variables
    $URI = '/api/types/smtpServer/instances' #########################################
    $Item = 'SMTP Server' #########################################
    $StatusCode = 201 #########################################
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      #### REQUEST BODY 

      <#

      #Creation of the body hash
      $body = @{}

      #Body arguments
      $body["address"] = $address
      $body["type"] = $type

      #>

      ####### END BODY - Do not edit beyond this line

      #Show $body in verbose message
      $Json = $body | ConvertTo-Json -Depth 10
      Write-Verbose $Json  

        If ($Sess.TestConnection()) {

          ##Building the URL
          $URL = 'https://'+$sess.Server+$URI
          Write-Verbose "URL: $URL"

          #Sending the request
          If ($pscmdlet.ShouldProcess($Sess.Name,"Create $Item $address")) {
            $request = Send-UnityRequest -uri $URL -Session $Sess -Method 'POST' -Body $Body
          }

          Write-Verbose "Request status code: $($request.StatusCode)"

          If ($request.StatusCode -eq $StatusCode) {

            #Formating the result. Converting it from JSON to a Powershell object
            $results = ($request.content | ConvertFrom-Json).content

            Write-Verbose "$Item with the ID $($results.id) has been created"

          #Executing Get-UnityUser with the ID of the new user
          Get-UnitySMTPServer -Session $Sess -ID $results.id
        } # End If ($request.StatusCode -eq $StatusCode)
      } # End If ($Sess.TestConnection()) 
    } # End Foreach ($sess in $session)
  } # End Process
} # End Function

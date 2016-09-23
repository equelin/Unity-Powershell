Function Set-UnityAlertConfig {

  <#
      .SYNOPSIS
      Modifies Alert Config.
      .DESCRIPTION
      Modifies Alert Config.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specify an UnitySession Object.
      .PARAMETER ID
      Config ALert ID or Object.
      .PARAMETER alertLocale
      Language in which the system sends email alerts.
      .PARAMETER isThresholdAlertsEnabled
      Whether pool space usage related alerts will be sent.
      .PARAMETER minEmailNotificationSeverity
      Minimum severity level for email alerts.
      .PARAMETER minSNMPTrapNotificationSeverity
      Minimum severity level for SNMP trap alerts.
      .PARAMETER destinationEmails
      List of emails to receive alert notifications.
      .PARAMETER Confirm
      If the value is $true, indicates that the cmdlet asks for confirmation before running. If the value is $false, the cmdlet runs without asking for user confirmation.
      .PARAMETER WhatIf
      Indicate that the cmdlet is run only to display the changes that would be made and actually no objects are modified.
      .EXAMPLE
      Set-UnityAlertConfig -destinationEmails 'mail@example.com'

      Modifies the default Alert Config
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    #Default Parameters
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),

    [Parameter(Mandatory = $false,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'ID of the Alert Config')]
    [String[]]$ID = '0',
    [Parameter(Mandatory = $false,HelpMessage = 'Language in which the system sends email alerts.')]
    [LocaleEnum]$alertLocale,
    [Parameter(Mandatory = $false,HelpMessage = 'Whether pool space usage related alerts will be sent.')]
    [bool]$isThresholdAlertsEnabled,
    [Parameter(Mandatory = $false,HelpMessage = 'Minimum severity level for email alerts.')]
    [SeverityEnum]$minEmailNotificationSeverity,
    [Parameter(Mandatory = $false,HelpMessage = 'Minimum severity level for SNMP trap alerts.')]
    [SeverityEnum]$minSNMPTrapNotificationSeverity,
    [Parameter(Mandatory = $false,HelpMessage = 'List of emails to receive alert notifications.')]
    [string[]]$destinationEmails
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"

    # Variables
    $URI = '/api/instances/alertConfig/<id>/action/modify'
    $Type = 'Alert Config' 
    $TypeName = 'UnityAlertConfig'
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
              $Object = get-UnityAlertConfig -Session $Sess -ID $i
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
              If ($Object = Get-UnityAlertConfig -Session $Sess -ID $ObjectID) {
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

            If ($PSBoundParameters.ContainsKey('alertLocale')) {
              $body["alertLocale"] = $alertLocale
            }

            If ($PSBoundParameters.ContainsKey('isThresholdAlertsEnabled')) {
              $body["isThresholdAlertsEnabled"] = $isThresholdAlertsEnabled
            }

            If ($PSBoundParameters.ContainsKey('minEmailNotificationSeverity')) {
              $body["minEmailNotificationSeverity"] = $minEmailNotificationSeverity
            }

            If ($PSBoundParameters.ContainsKey('minSNMPTrapNotificationSeverity')) {
              $body["minSNMPTrapNotificationSeverity"] = $minSNMPTrapNotificationSeverity
            }

            If ($PSBoundParameters.ContainsKey('destinationEmails')) {
              $body['destinationEmails'] = @()

              Foreach ($email in $destinationEmails) {
                $body["destinationEmails"] += $email
              }
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
            If ($pscmdlet.ShouldProcess($Sess.Name,"Modify $Type $ObjectName")) {
              $request = Send-UnityRequest -uri $URL -Session $Sess -Method 'POST' -Body $Body
            }

            If ($request.StatusCode -eq $StatusCode) {

              Write-Verbose "$Type with ID $ObjectID has been modified"

              Get-UnityAlertConfig -Session $Sess -id $ObjectID

            }  # End If ($request.StatusCode -eq $StatusCode)
          } else {
            Write-Warning -Message "$Type with ID $i does not exist on the array $($sess.Name)"
          } # End If ($ObjectID)
        } # End Foreach ($i in $ID)
      } # End If ($Sess.TestConnection()) 
    } # End Foreach ($sess in $session)
  } # End Process
} # End Function

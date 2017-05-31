Function Set-UnitySystem {

  <#
      .SYNOPSIS
      Modifies Unity storage system.
      .DESCRIPTION
      Modifies Unity storage system.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specify an UnitySession Object.
      .PARAMETER ID
      ID or Object.
      .PARAMETER name
      New name of the Unity
      .PARAMETER isUpgradeCompleted
      Indicates whether to manually mark an upgrade process completed.
      .PARAMETER isEulaAccepted
      Indicates whether to accept the End User License Agreement (EULA).
      .PARAMETER isAutoFailbackEnabled
      Indicates whether to enable the automatic failback of NAS servers in the system.
      .PARAMETER Confirm
      If the value is $true, indicates that the cmdlet asks for confirmation before running. If the value is $false, the cmdlet runs without asking for user confirmation.
      .PARAMETER WhatIf
      Indicate that the cmdlet is run only to display the changes that would be made and actually no objects are modified.
      .EXAMPLE
      Set-UnitySystem -ID '0' -isEULAAccepted $True

      Accept the EULA.
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    #Default Parameters
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),

    [Parameter(Mandatory = $false,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'ID or Object')]
    [Object[]]$ID = '0',
    [Parameter(Mandatory = $false,HelpMessage = 'New name of the Unity')]
    [String]$name,
    [Parameter(Mandatory = $false,HelpMessage = 'Indicates whether to manually mark an upgrade process completed')]
    [bool]$isUpgradeCompleted,
    [Parameter(Mandatory = $false,HelpMessage = 'Indicates whether to accept the End User License Agreement (EULA)')]
    [bool]$isEulaAccepted,
    [Parameter(Mandatory = $false,HelpMessage = 'Indicates whether to enable the automatic failback of NAS servers in the system')]
    [bool]$isAutoFailbackEnabled
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    # Variables
    $URI = '/api/instances/system/<id>/action/modify'
    $Type = 'System'
    $TypeName = 'UnitySystem'
    $StatusCode = 204
  }

  Process {

    Foreach ($sess in $session) {

      Write-Debug -Message "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If ($Sess.TestConnection()) {

          # Determine input and convert to object if necessary
          $Object,$ObjectID,$ObjectName = Get-UnityObject -Data $i -Typename $Typename -Session $Sess

          If ($ObjectID) {

            #### REQUEST BODY 

            # Creation of the body hash
            $body = @{}

            If ($PSBoundParameters.ContainsKey('name')) {
                  $body["name"] = $name
            }

            If ($PSBoundParameters.ContainsKey('isUpgradeCompleted')) {
                  $body["isUpgradeCompleted"] = $isUpgradeCompleted
            }

            If ($PSBoundParameters.ContainsKey('isEulaAccepted')) {
                  $body["isEulaAccepted"] = $isEulaAccepted
            }

            If ($PSBoundParameters.ContainsKey('isAutoFailbackEnabled')) {
                  $body["isAutoFailbackEnabled"] = $isAutoFailbackEnabled
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

              Get-UnitySystem -Session $Sess -id $ObjectID

            }  # End If ($request.StatusCode -eq $StatusCode)
          } else {
            Write-Warning -Message "$Type with ID $i does not exist on the array $($sess.Name)"
          } # End If ($ObjectID)
      } # End If ($Sess.TestConnection()) 
    } # End Foreach ($sess in $session)
  } # End Process
} # End Function

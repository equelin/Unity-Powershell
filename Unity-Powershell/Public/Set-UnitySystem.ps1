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
    [String]$ID = '0',
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
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"
  }

  Process {

    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If ($Sess.TestConnection()) {

        # Determine input and convert to UnitySystem object

        Write-Verbose "Input object type is $($ID.GetType().Name)"
        Switch ($ID.GetType().Name)
        {
          "String" {
            $UnitySystem = get-UnitySystem -Session $Sess -ID $ID
            $UnitySystemID = $UnitySystem.id
          }
          "UnitySystem" {
            $UnitySystemID = $ID.id
          }
        }

        If ($UnitySystemID) {

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

          #Building the URI
          $URI = 'https://'+$sess.Server+'/api/instances/system/'+$UnitySystemID+'/action/modify'
          Write-Verbose "URI: $URI"

          #Sending the request
          If ($pscmdlet.ShouldProcess($UnitySystemID,"Modify Unity Server")) {
            $request = Send-UnityRequest -uri $URI -Session $Sess -Method 'POST' -Body $Body
          }

          If ($request.StatusCode -eq '204') {

            Write-Verbose "Unity Server with ID: $UnitySystemID has been modified"

            Get-UnitySystem -Session $Sess -id $UnitySystemID

          }
        } else {
          Write-Verbose "Unity Server $UnitySystemID does not exist on the array $($sess.Name)"
        }
      } else {
        Write-Information -MessageData "You are no longer connected to EMC Unity array: $($Sess.Server)"
      }
    }
  }

  End {}
}

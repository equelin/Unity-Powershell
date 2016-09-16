Function Set-UnityNTPServer {

  <#
      .SYNOPSIS
      Modifies NTP Servers parameters.
      .DESCRIPTION
      Modifies NTP Servers parameters.
      You can configure a total of four NTP server addresses for the system. 
      All NTP server addresses are grouped into a single NTP server record. 
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specify an UnitySession Object.
      .PARAMETER Addresses
      List of NTP server IP addresses.
      .PARAMETER rebootPrivilege
      Indicates whether a system reboot of the NTP server is required for setting the system time.
      .PARAMETER Confirm
      If the value is $true, indicates that the cmdlet asks for confirmation before running. If the value is $false, the cmdlet runs without asking for user confirmation.
      .PARAMETER WhatIf
      Indicate that the cmdlet is run only to display the changes that would be made and actually no objects are modified.
      .EXAMPLE
      Set-UnityNTPServer -Addresses '192.168.0.1','192.168.0.2'

      replace the exsting address list for this NTP server with this new list.
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'List of NTP server IP addresses.')]
    [String[]]$Addresses,
    [Parameter(Mandatory = $false,HelpMessage = 'Indicates whether a system reboot of the NTP server is required for setting the system time.')]
    [RebootPrivilegeEnum]$rebootPrivilege = 'No_Reboot_Allowed'
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"

    # Variables
    $URI = '/api/instances/ntpServer/<id>/action/modify'
    $Type = 'NTP Server'
    $StatusCode = 204
  }

  Process {

    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If ($Sess.TestConnection()) {

          $Object = Get-UnityNTPServer -Session $Sess
          $ObjectID = $Object.id

          #### REQUEST BODY 

          # Creation of the body hash
          $body = @{}
          $body['addresses'] = @()

          Foreach ($Addresse in $Addresses) {
            $body["addresses"] += $Addresse
          }

          $body["rebootPrivilege"] = $rebootPrivilege

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

            Get-UnityPool -Session $Sess -id $ObjectID

          }  # End If ($request.StatusCode -eq $StatusCode)
        } else {
          Write-Warning -Message "$Type with ID $i does not exist on the array $($sess.Name)"
        } # End If ($Sess.TestConnection()) 
    } # End Foreach ($sess in $session)
  } # End Process
} # End Function

Function Set-UnityTreeQuota {

  <#
      .SYNOPSIS
      Modifies storage TreeQuota parameters.
      .DESCRIPTION
      Modifies storage TreeQuota parameters.
      You need to have an active session with the array.
      .NOTES
      Written by Albert Hugas under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
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
      ID of the TreeQuota or TreeQuota Object.
      .PARAMETER Description
      Description of the TreeQuota.
      .PARAMETER HardLimit
      Hard limit of the TreeQuota. Srt to 0 to disable hard limit.
      .PARAMETER SoftLimit
      Soft limit of the TreeQuota. Srt to 0 to disable soft limit.
      .EXAMPLE
      Set-UnityTreeQuota -ID 'TreeQuota_10' -Description 'Modified description'

      Change the description of the TreeQuota with ID 'TreeQuota_10'
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High',DefaultParameterSetName="RaidGroup")]
  Param (
    #Default Parameters
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),

    #UnityTreeQuota
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'TreeQuota ID or TreeQuota Object')]
    [Object[]]$ID,
    [Parameter(Mandatory = $false,HelpMessage = 'the treeQuota description')]
    [String]$Description,
    [Parameter(Mandatory = $false,HelpMessage = 'TreeQuotas hard limit')]
    [uint64]$HardLimit,
    [Parameter(Mandatory = $false,HelpMessage = 'TreeQuotas soft limit')]
    [uint64]$SoftLimit
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    # Variables
    $URI = '/api/instances/treeQuota/<id>/action/modify'
    $Type = 'treeQuota'
    $TypeName = 'UnitytreeQuota'
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

            #### REQUEST BODY 

            # Creation of the body hash
            $body = @{}

            # Description parameter
            If ($Description) {
                  $body["description"] = "$($Description)"
            }

            If ($HardLimit) {
                  $body["hardLimit"] = "$($HardLimit)"
            }

            If ($SoftLimit) {
                  $body["softLimit"] = "$($SoftLimit)"
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

              Get-UnityTreeQuota -Session $Sess -id $ObjectID

            }  # End If ($request.StatusCode -eq $StatusCode)
          } else {
            Write-Warning -Message "$Type with ID $i does not exist on the array $($sess.Name)"
          } # End If ($ObjectID)
        } # End Foreach ($i in $ID)
      } # End If ($Sess.TestConnection()) 
    } # End Foreach ($sess in $session)
  } # End Process
} # End Function

Function Invoke-UnityRefreshLUNThinClone {

    <#
    .SYNOPSIS
    Refresh a LUN thin clone.
    .DESCRIPTION
    Refresh a LUN thin clone.
    .NOTES
    Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
    .LINK
    https://github.com/equelin/Unity-Powershell
    .PARAMETER Session
    Specify an UnitySession Object.
    .PARAMETER LUN
    LUN id or Object
    .PARAMETER Snap
    The reference to the new source snapshot object. The new source snapshot may be any snap of this Thin Clone's base storage resource, including the current one.
    .PARAMETER copyName
    Name of the snapshot copy created before the refresh operation occurs.
    .PARAMETER Force
    When set, the refresh operation will proceed even if host access is configured on the storage resource.
    .PARAMETER Confirm
    If the value is $true, indicates that the cmdlet asks for confirmation before running. If the value is $false, the cmdlet runs without asking for user confirmation.
    .PARAMETER WhatIf
    Indicate that the cmdlet is run only to display the changes that would be made and actually no objects are modified.
    .EXAMPLE
    $Snap = Get-UnityLUN -Name 'LUN01' | New-UnitySnap -isAutoDelete:$false
    $ThinClone = Get-UnityLUN -Name 'LUN01-ThinClone'
    Invoke-UnityRefreshLUNThinClone -LUN $ThinClone.id -snap $snap.id -copyName 'LUN01-Snapshot'
    #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    #Default Parameters
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    
    #UnityLUNThinClone
    [Parameter(Mandatory = $true,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'LUN ID or object.')]
    [Object]$LUN,
    [Parameter(Mandatory = $true,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Snapshot ID')]
    [Object]$snap,
    [Parameter(Mandatory = $true,HelpMessage = 'Name of the snapshot copy created before the refresh operation occurs.')]
    [String]$copyName,
    [Parameter(Mandatory = $false,HelpMessage = 'When set, the refresh operation will proceed even if host access is configured on the storage resource.')]
    [Switch]$force
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand.Name)] Executing function"
    Write-Debug -Message "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
    Write-Debug -Message "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

    ## Variables
    $URI = '/api/instances/storageResource/<id>/action/refresh'
    $Type = 'ThinClone'
    $StatusCode = 200
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      # Determine input and convert to object if necessary

      Write-Verbose "Input object type is $($LUN.GetType().Name)"
      Switch ($LUN.GetType().Name)
      {
        "UnityLUN" {
          $ObjectID = $LUN.storageResource.id
        }

        "String" {
          If ($Object = Get-UnityLUN -Session $Sess -ID $LUN -ErrorAction SilentlyContinue) {
            $ObjectID = $Object.storageResource.id
          } else {
            Throw "This LUN does not exist"
          }
        }
      }

      #### REQUEST BODY 

      # Creation of the body hash
      $body = @{}

      #Snap
      $body["snap"] = @{}
        $snapParameter = @{}
        $snapParameter["id"] = $snap
      $body["snap"] = $snapParameter

      #Name
      $body["copyName"] = $copyName

      #Description
      If ($PSBoundParameters.ContainsKey('force')) {
            $body["force"] = $true
      }

      ####### END BODY - Do not edit beyond this line

      #Show $body in verbose message
      $Json = $body | ConvertTo-Json -Depth 10
      Write-Verbose $Json  

      If ($Sess.TestConnection()) {

        #Building the URL
        $FinalURI = $URI -replace '<id>',$ObjectID

        ##Building the URL
        $URL = 'https://'+$sess.Server+$FinalURI
        Write-Verbose "URL: $URL"

        #Sending the request
        If ($pscmdlet.ShouldProcess($Sess.Name,"Refresh $Type with ID $ObjectID")) {
          $request = Send-UnityRequest -uri $URL -Session $Sess -Method 'POST' -Body $Body
        }

        Write-Verbose "Request status code: $($request.StatusCode)"

        Write-Debug -Message "[$($MyInvocation.MyCommand.Name)] Request result: $($request | Out-String)"

        If ($request.StatusCode -eq $StatusCode) {

          #Formating the result. Converting it from JSON to a Powershell object
          $results = ($request.content | ConvertFrom-Json).content

          Write-Verbose "Snap with the ID $($results.copy.id) has been created"

          Get-UnitySnap -Session $Sess -ID $results.copy.id
        } # End If ($request.StatusCode -eq $StatusCode)
      } # End If ($Sess.TestConnection()) 
    } # End Foreach ($sess in $session)
  } # End Process
} # End Function
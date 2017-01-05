Function New-UnityMetricRealTimeQuery {

  <#
      .SYNOPSIS
      Creates a new metrics real-time query.
      .DESCRIPTION
      Creates a new metrics real-time query.
      After you create this query, the results are available whith the command Get-UnityMetricQueryResult
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specify an UnitySession Object.
      .PARAMETER paths
      Metric stat paths associated with the query. 
      .PARAMETER interval
      Sampling frequency for the query in seconds.
      .PARAMETER Confirm
      If the value is $true, indicates that the cmdlet asks for confirmation before running. If the value is $false, the cmdlet runs without asking for user confirmation.
      .PARAMETER WhatIf
      Indicate that the cmdlet is run only to display the changes that would be made and actually no objects are modified.
      .EXAMPLE
      New-UnityMetricRealTimeQuery -paths sp.*.cpu.uptime -interval 60

      Create a new query to gather statisitics about 'sp.*.cpu.uptime'. 
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    #Default Parameters
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    
    #UnityMetricRealTimeQuery
    [Parameter(Mandatory = $true,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Metric stat paths associated with the query.')]
    $paths,
    [Parameter(Mandatory = $true,HelpMessage = 'Sampling frequency for the query.')]
    [Uint64]$interval
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"

    ## Variables
    $URI = '/api/types/metricRealTimeQuery/instances'
    $Type = 'Real Time Metric Query'
    $StatusCode = 201
  }

  Process {
    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      #### REQUEST BODY 

      # Creation of the body hash
      $body = @{}

      $body["paths"] = @()

      foreach ($path in $paths) {
        $body["paths"] += $path
      }
        
      $body["interval"] = $interval

      ####### END BODY - Do not edit beyond this line

      #Show $body in verbose message
      $Json = $body | ConvertTo-Json -Depth 10
      Write-Verbose $Json  

      If ($Sess.TestConnection()) {

        ##Building the URL
        $URL = 'https://'+$sess.Server+$URI
        Write-Verbose "URL: $URL"

        #Sending the request
        If ($pscmdlet.ShouldProcess($Sess.Name,"Create $Type on storage resource ID $ObjectID")) {
          $request = Send-UnityRequest -uri $URL -Session $Sess -Method 'POST' -Body $Body
        }

        Write-Verbose "Request status code: $($request.StatusCode)"

        If ($request.StatusCode -eq $StatusCode) {

          #Formating the result. Converting it from JSON to a Powershell object
          $results = ($request.content | ConvertFrom-Json).content

          Write-Verbose "$Type with the ID $($results.id) has been created"

          Get-UnityMetricRealTimeQuery -Session $Sess -ID $results.id
        } # End If ($request.StatusCode -eq $StatusCode)
      } # End If ($Sess.TestConnection()) 
    } # End Foreach ($sess in $session)
  } # End Process
} # End Function
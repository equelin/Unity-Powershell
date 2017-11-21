Function Get-UnityMetricQueryResult {

  <#
      .SYNOPSIS
      A set of values for one or more metrics for a given period of time.
      .DESCRIPTION
      A set of values for one or more metrics for a given period of time.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specifies an UnitySession Object.
      .PARAMETER queryId
      Queries ID or object.
      .EXAMPLE
      Get-UnityMetricQueryResult -queryId 5

      Retrieve informations about query who's ID is 5.
      .EXAMPLE
      $query = New-UnityMetricRealTimeQuery -paths 'sp.*.cpu.core.*.busyTicks' -interval 30
      $query | Get-UnityMetricQueryResult

      Get query results using pipeline.
  #>

  [CmdletBinding()]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $true,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Queries ID or object')]
    [Object[]]$queryId
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand.Name)] Executing function"
    Write-Debug -Message "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
    Write-Debug -Message "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

    #Initialazing variables
    $URI = '/api/types/metricQueryResult/instances' #URI for the ressource (example: /api/types/lun/instances)
    $TypeName = 'UnityMetricQueryResult'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If ($Sess.TestConnection()) {

          Foreach ($Query in $QueryID) {

            # Determine input and convert to object if necessary

            Write-Verbose "Input object type is $($Query.GetType().Name)"
            Switch -wildcard ($Query.GetType().Name)
            {
              "UnityMetricRealTimeQuery" {
                $ObjectID = $Query.id
              }

              "*Int*" {
                If ($Object = Get-UnityMetricRealTimeQuery -Session $Sess -ID $Query -ErrorAction SilentlyContinue) {
                  $ObjectID = $Object.id
                } else {
                  Throw "This query does not exist"
                }
              }
            }

            $Filter = "queryId EQ $ObjectID"

            #Building the URL from Object Type.
            $URL = Get-URLFromObjectType -Session $sess -URI $URI -TypeName $TypeName -Compact -Filter $Filter

            Write-Verbose "URL: $URL"

            #Sending the request
            $request = Send-UnityRequest -uri $URL -Session $Sess -Method 'GET'

            #Formating the result. Converting it from JSON to a Powershell object
            $Results = ($request.content | ConvertFrom-Json).entries.content

            #Building the result collection (Add ressource type)
            If ($Results) {

              Foreach ($Result in $Results) {

                New-UnityObject -TypeName $TypeName -Data $Result

              } # End Foreach ($Result in $ResultCollection)
            } # End If ($Results)
        } # End Foreach ($Query in $QueryID) {
      } # End If ($Sess.TestConnection()) 
    } # End Foreach ($sess in $session)
  } # End Process
} # End Function

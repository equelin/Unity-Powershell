Function Get-UnitymetricQueryResult {

  <#
      .SYNOPSIS
      A set of values for one or more metrics for a given period of time. Each metricQueryResult resource is associated with a metricRealTimeQuery resource (VNXe or Unisphere Central) or metricHistoricalQuery resource (Unisphere Central only). <p/> After you create a query, the results are available as a set of metricQueryResult resources, where the queryId attribute of each metricQueryResult resource matches the id attribute of the associated metricRealTimeQuery or metricHistoricalQuery resource. <p/> You can optionally delete the metricRealTimeQuery resource when it is no longer needed, or it will be deleted automatically when the expiration reached. This API requires a ?filter= URL parameter that filters on a valid queryId. <p/> An example of a valid filter: <br>https://IP/api/types/metricQueryResult/instances?filter=queryId EQ 1  
      .DESCRIPTION
      A set of values for one or more metrics for a given period of time. Each metricQueryResult resource is associated with a metricRealTimeQuery resource (VNXe or Unisphere Central) or metricHistoricalQuery resource (Unisphere Central only). <p/> After you create a query, the results are available as a set of metricQueryResult resources, where the queryId attribute of each metricQueryResult resource matches the id attribute of the associated metricRealTimeQuery or metricHistoricalQuery resource. <p/> You can optionally delete the metricRealTimeQuery resource when it is no longer needed, or it will be deleted automatically when the expiration reached. This API requires a ?filter= URL parameter that filters on a valid queryId. <p/> An example of a valid filter: <br>https://IP/api/types/metricQueryResult/instances?filter=queryId EQ 1  
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specifies an UnitySession Object.
      .PARAMETER ID
      Specifies the object ID.
      .EXAMPLE
      Get-UnitymetricQueryResult

      Retrieve information about all UnitymetricQueryResult
      .EXAMPLE
      Get-UnitymetricQueryResult -ID 'id01'

      Retrieves information about a specific UnitymetricQueryResult
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnitymetricQueryResult ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/metricQueryResult/instances' #URI
    $TypeName = 'UnitymetricQueryResult'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


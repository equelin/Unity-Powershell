Function Get-UnitymetricRealTimeQuery {

  <#
      .SYNOPSIS
      Represents a query to obtain real-time information for one or more metrics, including a specified sampling frequency. <p/> After you create this query, the results are available as a set of metricQueryResult resources, where the queryId attribute of each metricQueryResult resource matches the id attribute of the associated metricRealTimeQuery resource (VNXe and Unisphere Central) or metricHistoricalQuery resource (Unisphere Central only). <p/> You can optionally delete the metricRealTimeQuery resource when it is no longer needed, or the resource will be deleted automatically when expiration is reached. <p/> <b>Note:</b> The metricRealTimeQuery resource does not support the filtering of response data.  
      .DESCRIPTION
      Represents a query to obtain real-time information for one or more metrics, including a specified sampling frequency. <p/> After you create this query, the results are available as a set of metricQueryResult resources, where the queryId attribute of each metricQueryResult resource matches the id attribute of the associated metricRealTimeQuery resource (VNXe and Unisphere Central) or metricHistoricalQuery resource (Unisphere Central only). <p/> You can optionally delete the metricRealTimeQuery resource when it is no longer needed, or the resource will be deleted automatically when expiration is reached. <p/> <b>Note:</b> The metricRealTimeQuery resource does not support the filtering of response data.  
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
      Get-UnitymetricRealTimeQuery

      Retrieve information about all UnitymetricRealTimeQuery
      .EXAMPLE
      Get-UnitymetricRealTimeQuery -ID 'id01'

      Retrieves information about a specific UnitymetricRealTimeQuery
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnitymetricRealTimeQuery ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/metricRealTimeQuery/instances' #URI
    $TypeName = 'UnitymetricRealTimeQuery'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


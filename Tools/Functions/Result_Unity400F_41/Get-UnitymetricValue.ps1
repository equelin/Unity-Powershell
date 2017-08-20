Function Get-UnitymetricValue {

  <#
      .SYNOPSIS
      Historical values for requested metrics. <p/> <b>Note:</b> The maximum number of returned instances per page is 5 for the metricValue resource type. For more information about paging, see the <i>Unisphere Management REST API Programmer's Guide</i>. <br>Unlike other REST GETs, this API requires a ?filter= URL parameter that filters on at least <u>path</u>. It must be filtered to one or more paths <br><u>An example of a valid filter(s) :</u> <br>https://IP/api/types/metricValue/instances?filter=path EQ "sp.*.physical.disk.*.responseTime"  
      .DESCRIPTION
      Historical values for requested metrics. <p/> <b>Note:</b> The maximum number of returned instances per page is 5 for the metricValue resource type. For more information about paging, see the <i>Unisphere Management REST API Programmer's Guide</i>. <br>Unlike other REST GETs, this API requires a ?filter= URL parameter that filters on at least <u>path</u>. It must be filtered to one or more paths <br><u>An example of a valid filter(s) :</u> <br>https://IP/api/types/metricValue/instances?filter=path EQ "sp.*.physical.disk.*.responseTime"  
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
      Get-UnitymetricValue

      Retrieve information about all UnitymetricValue
      .EXAMPLE
      Get-UnitymetricValue -ID 'id01'

      Retrieves information about a specific UnitymetricValue
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnitymetricValue ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/metricValue/instances' #URI
    $TypeName = 'UnitymetricValue'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


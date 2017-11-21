Function Get-UnityMetricValue {

  <#
      .SYNOPSIS
      Historical values for requested metrics. 
      .DESCRIPTION
      Historical values for requested metrics. 
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specifies an UnitySession Object.
      .PARAMETER Path
      Stat path for the metric. A stat path identifies the metric's location in the stats namespace.
      .PARAMETER Count
      Specifies the number of samples to display.
      .EXAMPLE
      Get-UnityMetricValue -Path 'sp.*.cpu.summary.utilization'

      Retrieves information about metrics who's path is 'sp.*.cpu.summary.utilization'
  #>

  [CmdletBinding()]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Stat path for the metric')]
    [Object[]]$Path,
    [Parameter(Mandatory = $false,HelpMessage = 'Specifies the number of samples to display')]
    [Int64]$Count = 20
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand.Name)] Executing function"
    Write-Debug -Message "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
    Write-Debug -Message "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

    #Initialazing variables
    $URI = '/api/types/metricValue/instances' #URI
    $TypeName = 'UnityMetricValue'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If ($Sess.TestConnection()) {

        Foreach ($P in $Path) {

          Write-Verbose "Processing path: $P"

          # Determine input and convert to object if necessary
          Write-Verbose "Input object type is $($P.GetType().Name)"
          Switch ($P.GetType().Name)
          {
            "UnityMetric" {$ObjectPath = $P.Path}
            "String" {$ObjectPath = $P}
          }

          Write-Verbose "Object path: $ObjectPath"

          $PathFilter = "filter=path EQ `"$ObjectPath`""
          $Page = '&page=1'
          $Results = @()

          While (($Results.count) -le $Count) {
            #Building the URL from Object Type.
            $URL = 'https://'+ $sess.Server + $URI +'?'+ $PathFilter + $Page
            Write-Verbose "URL: $URL"

            #Sending the request
            $request = Send-UnityRequest -uri $URL -Session $Sess -Method 'GET'

            #Formating the result. Converting it from JSON to a Powershell object
            $Results += ($request.content | ConvertFrom-Json).entries.content

            $Links = ($request.content | ConvertFrom-Json).links 

            $Page = ($links | Where-Object {$_.rel -eq 'next'}).href
          }

          #Building the result collection (Add ressource type)
          If ($Results) {

            $Results = $Results | Select-Object -First $Count

            Foreach ($Result in $Results) {

              # Instantiate object
              New-UnityObject -TypeName $TypeName -Data $Result

            } # End Foreach ($Result in $ResultCollection)
          } # End If ($Results)
        } # End Foreach ($P in $Path)
      } # End If ($Sess.TestConnection()) 
    } # End Foreach ($sess in $session)
  } # End Process
} # End Function

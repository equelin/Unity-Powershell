Function Get-UnityDataCollectionResult {

  <#
      .SYNOPSIS
      Information about Data Collection results in the storage system. Data Collection is a service feature used for gathering system logs, customer configurations, system statistics and runtime data from storage system.  
      .DESCRIPTION
      Information about Data Collection results in the storage system. Data Collection is a service feature used for gathering system logs, customer configurations, system statistics and runtime data from storage system.  
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specifies an UnitySession Object.
      .PARAMETER Name
      Specifies the object name.
      .PARAMETER ID
      Specifies the object ID.
      .PARAMETER Download
      Specifies if you want to download Data Collection Results
      .PARAMETER Path
      Specifies where to store downloaded Data Collection Results
      .EXAMPLE
      Get-UnityDataCollectionResultList

      Retrieve information about all UnitydataCollectionResult
      .EXAMPLE
      Get-UnityDataCollectionResultList -ID 'id01'

      Retrieves information about a specific UnitydataCollectionResult
      .EXAMPLE
      Get-UnityDataCollectionResultList -ID 'id01' -Download -Path C:\Temp

      Download Data Collection Result in C:\Temp
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='Name',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnitydataCollectionResult Name')]
    [String[]]$Name,
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnitydataCollectionResult ID')]
    [String[]]$ID,
    [Parameter(Mandatory = $false,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Download the file(s)')]
    [Switch]$Download,
    [Parameter(Mandatory = $false,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Download path')]
    [String]$Path ="."
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/dataCollectionResult/instances' #URI
    $TypeName = 'UnitydataCollectionResult'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      $Results = Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

      Foreach ($Result in $Results) {
        If ($Download) {
          
          $DownloadURI = "/download/dataCollectionResult/" + $Result.Id
          $OutFile = Join-Path -Path $Path -ChildPath $Result.Name

          Write-Verbose "Downloading file: $($Result.Name)"
          Write-Verbose "URI: $DownloadURI"
          Write-Verbose "OutFile: $OutFile"
          
          $Response = $Sess.SendGetRequest($DownloadURI,$OutFile)

          If ($Response.StatusCode -eq 200) {
            Get-Item $OutFile 
          }

        } else {
          $Result
        }
      }
    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


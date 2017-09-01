Function Get-UnityDataCollectionResult {

  <#
      .SYNOPSIS
      Get or download informations about Data Collection results
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
      .PARAMETER Compress
      Specifies if you want to compress the downloaded file
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

  [CmdletBinding(DefaultParameterSetName='ID')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='Name',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnitydataCollectionResult Name')]
    [String[]]$Name,
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnitydataCollectionResult ID')]
    [String[]]$ID,
    [Parameter(Mandatory = $false,HelpMessage = 'Download the file(s)')]
    [Switch]$Download,
    [Parameter(Mandatory = $false,HelpMessage = 'Zip the downloaded file(s)')]
    [Switch]$Compress,
    [Parameter(Mandatory = $false,HelpMessage = 'Download path')]
    [validatescript({Test-Path $_})]
    [String]$Path ="."
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand.Name)] Executing function"
    Write-Debug -Message "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
    Write-Debug -Message "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

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

          Write-Debug -Message "[$($MyInvocation.MyCommand)] Downloading file: $($Result.Name)"
          Write-Debug -Message "[$($MyInvocation.MyCommand)] URI: $DownloadURI"
          Write-Debug -Message "[$($MyInvocation.MyCommand)] OutFile: $OutFile"

          If (Test-Path $OutFile) {
            Throw "File $OutFile already exists"
          }
          
          $Response = $Sess.SendGetRequest($DownloadURI,$OutFile)

          If (($Response.StatusCode -eq 200) -and (Test-Path $OutFile)) {
            If ($PSBoundParameters.ContainsKey('Compress')) {
              $CompressFile = "$OutFile.zip"
              Write-Debug -Message "[$($MyInvocation.MyCommand)] Compress file $OutFile. Destination file is $CompressFile"
              # Compress downloaded file and return it
              Compress-Archive -LiteralPath $OutFile -CompressionLevel 'Fastest' -DestinationPath $CompressFile -Force | Out-Null

              Write-Debug -Message "[$($MyInvocation.MyCommand)] Delete file $OutFile"
              Remove-Item $OutFile -Confirm:$false -Force | Out-Null

              #Return compressed item
              Get-Item $CompressFile
            } else {
              #Return downloaded item
              Get-Item $OutFile
            } 
          }

        } else {
          $Result
        }
      }
    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


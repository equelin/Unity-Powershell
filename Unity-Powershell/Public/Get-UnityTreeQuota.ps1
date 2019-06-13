Function Get-UnityTreeQuota {

  <#
      .SYNOPSIS
      Queries the EMC Unity array to retrieve informations about treequotas.
      .DESCRIPTION
      Querries the EMC Unity array to retrieve informations about treequotas.
      You need to have an active session with the array.
      .NOTES
      Written by Albert Hugas under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specifies an UnitySession Object.
      .PARAMETER Path
      Specifies the treeQuota Path of the TreeQuota to return.
      .PARAMETER ID
      Specifies the TreeQuota ID.
      .PARAMETER Filesystem
      Specifies the filesystem where is the TreeQuota
      .PARAMETER State
      Specifies the TreeQuota states: 0=Ok, 3=xxx
      .EXAMPLE
      Get-UnityTreeQuota

      Retrieve information about treequota
      .EXAMPLE
      Get-UnityTreeQuota -ID 'treequota_123456_12'

      Retrieves information about treequota id treequota_123456_12
      .EXAMPLE
      $fs = Get-UnityFilesystem -Name 'TEST_FS'
      Get-UnityTreeQuota -filesystem $fs.Id

      Retrieves information about all treequota in filesystem 'TEST_FS'
  #>

  [CmdletBinding(DefaultParameterSetName="Filter")]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName="Path",ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Path Name')]
    [String[]]$Path,
    [Parameter(Mandatory = $false,ParameterSetName="ID",ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'TreeQuota ID')]
    [String[]]$ID,
    [Parameter(Mandatory = $false,ParameterSetName="Filter",HelpMessage = 'Filesystem')]
    [String[]]$Filesystem,
    [Parameter(Mandatory = $false,ParameterSetName="Filter",HelpMessage = 'TreeQuota State')]
    [String[]]$State

  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/treeQuota/instances' #URI
    $Typename = "UnitytreeQuota"
    $Filter = ""
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"
      
      # Process parameters to create search filter
      if ( $ID ) {
        $Filter = "id eq `"$ID`""
      } elseif ( $Path ) {
        $Filter = "path eq `"$Path`""
      }

      if ( $Filesystem ) {
        if ( $Filter ){ $Filter += " and " }
        $Filter += "filesystem eq `"$Filesystem`""
      }

      if ( $State ) {
        if ( $Filter ){ $Filter += " and " }
        $Filter += "state eq `"$State`""
      }
      
      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key "ID" -Filter $Filter

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function

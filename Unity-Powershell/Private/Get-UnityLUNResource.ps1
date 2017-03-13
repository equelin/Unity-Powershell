Function Get-UnityLUNResource {

  <#
      .SYNOPSIS
      Queries the EMC Unity array to retrieve informations about LUN.
      .DESCRIPTION
      Queries the EMC Unity array to retrieve informations about LUN.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence
      .LINK
      https://github.com/equelin/Unity-Powershell
      .EXAMPLE
      Get-UnityLUNResource

      Retrieve information about LUN
      .EXAMPLE
      Get-UnityLUNResource -Name 'LUN01'

      Retrieves information about LUN named LUN01
  #>

  [CmdletBinding(DefaultParameterSetName="Name")]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName="Name",ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'LUN Name')]
    [String[]]$Name,
    [Parameter(Mandatory = $false,ParameterSetName="ID",ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'LUN ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $ResultCollection = @()
    $URI = '/api/types/lun/instances' #URI for the ressource (example: /api/types/lun/instances)
    $TypeName = 'UnityLUN' 
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function

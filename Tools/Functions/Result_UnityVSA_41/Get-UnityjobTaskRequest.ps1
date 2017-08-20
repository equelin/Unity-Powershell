sFunction Get-UnityjobTaskRequest {

  <#
      .SYNOPSIS
      The batch job consists of a group of primitive REST API POST requests. Each is considered to be a task of the job. This object is to represent such primitive request. <br/> <br/> For information about jobs, see the Help topic for the job resource type.  
      .DESCRIPTION
      The batch job consists of a group of primitive REST API POST requests. Each is considered to be a task of the job. This object is to represent such primitive request. <br/> <br/> For information about jobs, see the Help topic for the job resource type.  
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
      .EXAMPLE
      Get-UnityjobTaskRequest

      Retrieve information about all UnityjobTaskRequest
      .EXAMPLE
      Get-UnityjobTaskRequest -ID 'id01'

      Retrieves information about a specific UnityjobTaskRequest
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='Name',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnityjobTaskRequest Name')]
    [String[]]$Name,
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnityjobTaskRequest ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/jobTaskRequest/instances' #URI
    $TypeName = 'UnityjobTaskRequest'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


Function Get-UnityJob {

  <#
      .SYNOPSIS
      Information about the jobs in the storage system. <br/> <br/> A job represents one management request, it consists of a series of tasks. <br/> A job could also contain a series of primitive REST API POST requests, each of which maps to a task in the job. Such job is known as "batch request job". <br/> Client can query the job instance to track its progress, results, and details of each task. <br/> <br/> When a job is failed, the system might leave hehind unneeded resources that consume space. You can manually delete any resources that were created for the failed job. <br/>  
      .DESCRIPTION
      Information about the jobs in the storage system. <br/> <br/> A job represents one management request, it consists of a series of tasks. <br/> A job could also contain a series of primitive REST API POST requests, each of which maps to a task in the job. Such job is known as "batch request job". <br/> Client can query the job instance to track its progress, results, and details of each task. <br/> <br/> When a job is failed, the system might leave hehind unneeded resources that consume space. You can manually delete any resources that were created for the failed job. <br/>  
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
      Get-UnityJob

      Retrieve information about all UnityJob
      .EXAMPLE
      Get-UnityJob -ID 'id01'

      Retrieves information about a specific UnityJob
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnityJob ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/job/instances' #URI
    $TypeName = 'UnityJob'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


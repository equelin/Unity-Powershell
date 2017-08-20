Function Get-UnitydhsmConnection {

  <#
      .SYNOPSIS
      When doing cloud archiving, the Cloud Tiering Applicance (a.k.a CTA) is responsible for moving the local data to cloud. On the other direction, when we need to bring the data back to local, DHSM server will read the data back via a pipe so called dhsm connection. This class represents this dhsm connection @author wangt23  
      .DESCRIPTION
      When doing cloud archiving, the Cloud Tiering Applicance (a.k.a CTA) is responsible for moving the local data to cloud. On the other direction, when we need to bring the data back to local, DHSM server will read the data back via a pipe so called dhsm connection. This class represents this dhsm connection @author wangt23  
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
      Get-UnitydhsmConnection

      Retrieve information about all UnitydhsmConnection
      .EXAMPLE
      Get-UnitydhsmConnection -ID 'id01'

      Retrieves information about a specific UnitydhsmConnection
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='Name',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnitydhsmConnection Name')]
    [String[]]$Name,
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnitydhsmConnection ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/dhsmConnection/instances' #URI
    $TypeName = 'UnitydhsmConnection'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


Function Get-UnityDiskGroup {

  <#
      .SYNOPSIS
      View details about disk groups on the system.
      .DESCRIPTION
      View details about disk groups on the system.
      Physical deployment only.
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
      Get-UnityDiskGroup

      Retrieve information about all disk groups
      .EXAMPLE
      Get-UnityDiskGroup -Name '200 GB SAS Flash 2'

      Retrieves information about disk groups names '200 GB SAS Flash 2'
  #>

  [CmdletBinding(DefaultParameterSetName="Name")]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName="Name",ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Disk group Name')]
    [String[]]$Name,
    [Parameter(Mandatory = $false,ParameterSetName="ID",ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Disk group ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/diskGroup/instances' #URI
    $TypeName = 'UnityDiskGroup'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      # Test if the Unity is a virtual appliance
      If ($Sess.isUnityVSA()) {

        Write-Warning -Message "This functionnality is not supported on the Unity VSA ($($Sess.Name))"
        
      } else {

        Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

      } # End If ($Sess.isUnityVSA())
    } # End Foreach ($sess in $session)
  } # End Process
} # End Function
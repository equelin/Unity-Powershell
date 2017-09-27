Function Get-UnityDae {

  <#
      .SYNOPSIS
      Information about Disk Array Enclosure (DAE) components in the storage system.  
      .DESCRIPTION
      Information about Disk Array Enclosure (DAE) components in the storage system.  
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
      Get-UnityDae

      Retrieve Information about Disk Array Enclosure (DAE) components in the storage system. 
  #>

  [CmdletBinding(DefaultParameterSetName="ID")]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName="Name",ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'DAE Name')]
    [String[]]$Name,
    [Parameter(Mandatory = $false,ParameterSetName="ID",ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'DAE ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/dae/instances' #URI for the ressource (example: /api/types/lun/instances)
    $TypeName = 'UnityDae'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      # Test if the Unity is a virtual appliance
      If ($Sess.isUnityVSA()) {

        Write-Error -Message "This functionnality is not supported on the Unity VSA ($($Sess.Name))" -Category "DeviceError"
        
      } else {

        Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

      } # End If ($Sess.isUnityVSA())
    } # End Foreach ($sess in $session)
  } # End Process
} # End Function

Function Get-UnityroleMapping {

  <#
      .SYNOPSIS
      Information about role mappings in the storage system. <br/> <br/> Each role mapping associates a local user, LDAP user, or LDAP group with a role, granting that user or group administrative privileges on the system. <br/> <br/> When you create a local user through the REST API, the appropriate role mapping between the new user and the specified role is created implicitly by the storage system. When you create an LDAP user or group through the REST API, you must explicitly specify a role mapping for that user or group by creating a new roleMapping resource. <br/> <br/> For information about creating local users, see the Help topic for the user resource type.  
      .DESCRIPTION
      Information about role mappings in the storage system. <br/> <br/> Each role mapping associates a local user, LDAP user, or LDAP group with a role, granting that user or group administrative privileges on the system. <br/> <br/> When you create a local user through the REST API, the appropriate role mapping between the new user and the specified role is created implicitly by the storage system. When you create an LDAP user or group through the REST API, you must explicitly specify a role mapping for that user or group by creating a new roleMapping resource. <br/> <br/> For information about creating local users, see the Help topic for the user resource type.  
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
      Get-UnityroleMapping

      Retrieve information about all UnityroleMapping
      .EXAMPLE
      Get-UnityroleMapping -ID 'id01'

      Retrieves information about a specific UnityroleMapping
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='Name',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnityroleMapping Name')]
    [String[]]$Name,
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnityroleMapping ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/roleMapping/instances' #URI
    $TypeName = 'UnityroleMapping'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


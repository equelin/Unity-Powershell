Function Get-UnitycertificateScope {

  <#
      .SYNOPSIS
      Scope of the certificate: <ul> <li>If the certificate scope is global, the attribute values are blank.</li> <li>If the certificate scope is local, the scope is defined by one attribute value (for queries) or one argument value (for create and import operations). For example, if the scope of the certificate is NAS server nas01, the value of the nasServer attribute would be nas01, and all other attributes would be blank.</li> </ul> <p> For information about which scopes apply to which services, see the help topic for the ServiceTypeEnum.  
      .DESCRIPTION
      Scope of the certificate: <ul> <li>If the certificate scope is global, the attribute values are blank.</li> <li>If the certificate scope is local, the scope is defined by one attribute value (for queries) or one argument value (for create and import operations). For example, if the scope of the certificate is NAS server nas01, the value of the nasServer attribute would be nas01, and all other attributes would be blank.</li> </ul> <p> For information about which scopes apply to which services, see the help topic for the ServiceTypeEnum.  
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
      Get-UnitycertificateScope

      Retrieve information about all UnitycertificateScope
      .EXAMPLE
      Get-UnitycertificateScope -ID 'id01'

      Retrieves information about a specific UnitycertificateScope
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnitycertificateScope ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/certificateScope/instances' #URI
    $TypeName = 'UnitycertificateScope'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


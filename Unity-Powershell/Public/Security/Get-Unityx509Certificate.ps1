Function Get-Unityx509Certificate {

  <#
      .SYNOPSIS
      Information about the X.509 certificates installed on the storage system. The X.509 certificate format is described in RFC 5280.  
      .DESCRIPTION
      Information about the X.509 certificates installed on the storage system. The X.509 certificate format is described in RFC 5280.  
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
      Get-Unityx509Certificate

      Retrieve information about all Unityx509Certificate
      .EXAMPLE
      Get-Unityx509Certificate -ID 'id01'

      Retrieves information about a specific Unityx509Certificate
  #>

  [CmdletBinding(DefaultParameterSetName='ID')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Unityx509Certificate ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/x509Certificate/instances' #URI
    $TypeName = 'Unityx509Certificate'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


Function Get-UnityvirusChecker {

  <#
      .SYNOPSIS
      Information about the anti-virus service of a NAS server. <br/> <br/> The storage system supports third-party anti-virus servers that perform virus scans and reports back to the storage system. For example, when an SMB client creates, moves, or modifies a file, the NAS server invokes the anti-virus server to scan the file for known viruses. During the scan any access to this file is blocked. If the file does not contain a virus, it is written to the file system. If the file is infected, corrective action (fixed, removed or placed in quarantine) is taken as defined by the anti-virus server. You can optionally set up the service to scan the file on read access based on last access of the file compared to last update of the third-party anti-virus date. <br/> A virusChecker object is created each time the anti-virus service is enabled on a NAS server. A configuration file (named viruschecker.conf) needs to be uploaded on the NAS server before enabling the anti-virus service.  
      .DESCRIPTION
      Information about the anti-virus service of a NAS server. <br/> <br/> The storage system supports third-party anti-virus servers that perform virus scans and reports back to the storage system. For example, when an SMB client creates, moves, or modifies a file, the NAS server invokes the anti-virus server to scan the file for known viruses. During the scan any access to this file is blocked. If the file does not contain a virus, it is written to the file system. If the file is infected, corrective action (fixed, removed or placed in quarantine) is taken as defined by the anti-virus server. You can optionally set up the service to scan the file on read access based on last access of the file compared to last update of the third-party anti-virus date. <br/> A virusChecker object is created each time the anti-virus service is enabled on a NAS server. A configuration file (named viruschecker.conf) needs to be uploaded on the NAS server before enabling the anti-virus service.  
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
      Get-UnityvirusChecker

      Retrieve information about all UnityvirusChecker
      .EXAMPLE
      Get-UnityvirusChecker -ID 'id01'

      Retrieves information about a specific UnityvirusChecker
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnityvirusChecker ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/virusChecker/instances' #URI
    $TypeName = 'UnityvirusChecker'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


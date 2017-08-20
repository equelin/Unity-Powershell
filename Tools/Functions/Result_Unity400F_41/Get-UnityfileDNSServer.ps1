Function Get-UnityfileDNSServer {

  <#
      .SYNOPSIS
      Domain Name System (DNS) settings object of NAS server. You can configure one DNS settings object per NAS server. <br/> A Domain Name System (DNS) is a hierarchical system responsible for converting domain names to their corresponding IP addresses. NAS server's DNS settings should allow DNS resolution of all names within SMB server's domain in order for SMB protocol to operate normally within an Active Directory domain.</p>  
      .DESCRIPTION
      Domain Name System (DNS) settings object of NAS server. You can configure one DNS settings object per NAS server. <br/> A Domain Name System (DNS) is a hierarchical system responsible for converting domain names to their corresponding IP addresses. NAS server's DNS settings should allow DNS resolution of all names within SMB server's domain in order for SMB protocol to operate normally within an Active Directory domain.</p>  
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
      Get-UnityfileDNSServer

      Retrieve information about all UnityfileDNSServer
      .EXAMPLE
      Get-UnityfileDNSServer -ID 'id01'

      Retrieves information about a specific UnityfileDNSServer
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnityfileDNSServer ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/fileDNSServer/instances' #URI
    $TypeName = 'UnityfileDNSServer'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


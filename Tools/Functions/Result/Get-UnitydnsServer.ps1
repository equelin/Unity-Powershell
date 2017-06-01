Function Get-UnitydnsServer {

  <#
      .SYNOPSIS
      Domain Name System (DNS) settings. <p/> A Domain Name System (DNS) is a hierarchical system responsible for converting domain names to their corresponding IP addresses. The system uses DNS services to resolve network names and IP addresses for the network services it needs (for example, for NTP and SMTP servers), and to obtain IP addresses for hosts addressed by network names rather than IP addresses. <p/> During the initial system configuration process you must specify the network address of at least one DNS server for resolving hostnames to IP addresses. Later, you can add, delete, or change DNS server settings. <p/> You can configure multiple DNS server domains to specify each domain and IP address of the DNS servers for the system to use. By default, the system uses the top entry in the list as the current DNS server. The remaining list provides a hierarchy of DNS servers to use if the first-choice server becomes unavailable. If the first DNS server in the list becomes unavailable, the system proceeds to the next DNS server in the list, and so on. You can also specify default DNS server addresses to indicate which addresses the system will use first. <p/> DNS server addresses are grouped under DNS server domains. Each domain is identified by a domain identifier. <p/> <b>Important:</b> You must configure at least one valid DNS server entry in the domain for the system. Deleting the last DNS server entry can disrupt network communication to the device, and potentially interrupt communication between the system and the hosts that use its storage resources.  
      .DESCRIPTION
      Domain Name System (DNS) settings. <p/> A Domain Name System (DNS) is a hierarchical system responsible for converting domain names to their corresponding IP addresses. The system uses DNS services to resolve network names and IP addresses for the network services it needs (for example, for NTP and SMTP servers), and to obtain IP addresses for hosts addressed by network names rather than IP addresses. <p/> During the initial system configuration process you must specify the network address of at least one DNS server for resolving hostnames to IP addresses. Later, you can add, delete, or change DNS server settings. <p/> You can configure multiple DNS server domains to specify each domain and IP address of the DNS servers for the system to use. By default, the system uses the top entry in the list as the current DNS server. The remaining list provides a hierarchy of DNS servers to use if the first-choice server becomes unavailable. If the first DNS server in the list becomes unavailable, the system proceeds to the next DNS server in the list, and so on. You can also specify default DNS server addresses to indicate which addresses the system will use first. <p/> DNS server addresses are grouped under DNS server domains. Each domain is identified by a domain identifier. <p/> <b>Important:</b> You must configure at least one valid DNS server entry in the domain for the system. Deleting the last DNS server entry can disrupt network communication to the device, and potentially interrupt communication between the system and the hosts that use its storage resources.  
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
      Get-UnitydnsServer

      Retrieve information about all UnitydnsServer
      .EXAMPLE
      Get-UnitydnsServer -ID 'id01'

      Retrieves information about a specific UnitydnsServer
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnitydnsServer ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/dnsServer/instances' #URI
    $TypeName = 'UnitydnsServer'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


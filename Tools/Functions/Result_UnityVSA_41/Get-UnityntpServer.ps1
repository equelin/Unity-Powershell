Function Get-UnityntpServer {

  <#
      .SYNOPSIS
      Network Time Protocol (NTP) server settings. <br/> <br/> The system relies on NTP as a standard for synchronizing the system clock with other nodes on the network. NTP provides a way of synchronizing clocks of distributed systems within approximately one millisecond of each other. A Windows Active Directory domain controller can operate as a time server if the Windows Time Service is running on it. <br/> <br/> Some applications will not operate correctly if the clock on the system is not synchronized with the clock on connected hosts. Configure the system and any connected hosts to use the same time server. Doing so does the following: <ul> <li> Minimizes the chance that synchronization issues will arise between the system and connected hosts. </li> <li> Reduces the difficulty of reconciling timestamps used for log information in the different systems. </li> </ul> <b>Note:</b><b> </b>When using a NAS server for CIFS network shares, the system cannot access an Active Directory domain unless the system is synchronized within five minutes of the Active Directory controller for the domain where the network shares reside. <br/> <br/> You can configure a total of four NTP server addresses for the system. All NTP server addresses are grouped into a single NTP server record.  
      .DESCRIPTION
      Network Time Protocol (NTP) server settings. <br/> <br/> The system relies on NTP as a standard for synchronizing the system clock with other nodes on the network. NTP provides a way of synchronizing clocks of distributed systems within approximately one millisecond of each other. A Windows Active Directory domain controller can operate as a time server if the Windows Time Service is running on it. <br/> <br/> Some applications will not operate correctly if the clock on the system is not synchronized with the clock on connected hosts. Configure the system and any connected hosts to use the same time server. Doing so does the following: <ul> <li> Minimizes the chance that synchronization issues will arise between the system and connected hosts. </li> <li> Reduces the difficulty of reconciling timestamps used for log information in the different systems. </li> </ul> <b>Note:</b><b> </b>When using a NAS server for CIFS network shares, the system cannot access an Active Directory domain unless the system is synchronized within five minutes of the Active Directory controller for the domain where the network shares reside. <br/> <br/> You can configure a total of four NTP server addresses for the system. All NTP server addresses are grouped into a single NTP server record.  
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
      Get-UnityntpServer

      Retrieve information about all UnityntpServer
      .EXAMPLE
      Get-UnityntpServer -ID 'id01'

      Retrieves information about a specific UnityntpServer
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnityntpServer ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/ntpServer/instances' #URI
    $TypeName = 'UnityntpServer'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


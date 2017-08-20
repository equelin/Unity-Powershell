Function Get-Unityroute {

  <#
      .SYNOPSIS
      Manages static IP routes, including creating, modifying, and deleting these routes. <p/> A route determines where to send a packet next so it can reach its final destination. A static route is set explicitly and does not automatically adapt to the changing network infrastructure. A route is defined by an interface, destination IP address range and an IP address of a corresponding gateway. <p/> <b>Note: </b>IP routes connect an interface (IP address) to the larger network through gateways. Without routes, the interface is no longer accessible outside of its immediate subnet. As a result, network shares and exports associated with the interface are no longer available to clients outside their immediate subnet. <p/> Routes can be created only for iSCSI portals.  
      .DESCRIPTION
      Manages static IP routes, including creating, modifying, and deleting these routes. <p/> A route determines where to send a packet next so it can reach its final destination. A static route is set explicitly and does not automatically adapt to the changing network infrastructure. A route is defined by an interface, destination IP address range and an IP address of a corresponding gateway. <p/> <b>Note: </b>IP routes connect an interface (IP address) to the larger network through gateways. Without routes, the interface is no longer accessible outside of its immediate subnet. As a result, network shares and exports associated with the interface are no longer available to clients outside their immediate subnet. <p/> Routes can be created only for iSCSI portals.  
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
      Get-Unityroute

      Retrieve information about all Unityroute
      .EXAMPLE
      Get-Unityroute -ID 'id01'

      Retrieves information about a specific Unityroute
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Unityroute ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/route/instances' #URI
    $TypeName = 'Unityroute'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


Function Set-UnityFileInterface {

  <#
      .SYNOPSIS
      Modifies NAS Server parameters.
      .DESCRIPTION
      Modifies NAS Server parameters.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .EXAMPLE
      Set-UnityFileInterface -ID 'if_1' -ipAddress '192.168.0.1'

      Change ip of the file interface with ID 'if_1'
  #>

    [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'File interface ID or Object')]
    $ID,
    [Parameter(Mandatory = $false,HelpMessage = 'Physical port or link aggregation on the storage processor on which the interface is running')]
    $ipPort,
    [Parameter(Mandatory = $false,HelpMessage = 'IP address of the network interface')]
    [ipaddress]$ipAddress,
    [Parameter(Mandatory = $false,HelpMessage = 'IPv4 netmask for the network interface, if it uses an IPv4 address')]
    [ipaddress]$netmask,
    [Parameter(Mandatory = $false,HelpMessage = 'IPv6 prefix length for the interface, if it uses an IPv6 address')]
    [String]$v6PrefixLength,
    [Parameter(Mandatory = $false,HelpMessage = 'IPv4 or IPv6 gateway address for the network interface')]
    [ipaddress]$gateway,
    [Parameter(Mandatory = $false,HelpMessage = ' VLAN identifier for the interface. The interface uses the identifier to accept packets that have matching VLAN tags. Values are 1 - 4094.')]
    [int]$vlanId,
    [Parameter(Mandatory = $false,HelpMessage = 'Sets the current IP interface as preferred for associated for file-based storage and unsets the previous one')]
    [bool]$isPreferred,
    [Parameter(Mandatory = $false,HelpMessage = 'Indicates the status of the NAS server object operating as a replication destination')]
    [String]$replicationPolicy
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"

    $ReplicationPolicyEnum = @{
      "Not_Replicated" = "0"
      "Replicated" = "1"
      "Overridden" = "2"
    }
  }

  Process {

    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If ($Sess.TestConnection()) {

        # Determine input and convert to UnityPool object
        Switch ($ID.GetType().Name)
        {
          "String" {
            $FileInterface = get-UnityFileInterface -Session $Sess -ID $ID
            $FileInterfaceID = $FileInterface.id
            $FileInterfaceName = $FileInterface.Name
          }
          "UnityFileInterface" {
            Write-Verbose "Input object type is $($ID.GetType().Name)"
            $FileInterfaceID = $ID.id
            If ($FileInterface = Get-UnityFileInterface -Session $Sess -ID $FileInterfaceID) {
                      $FileInterfaceName = $ID.name
            }
          }
        }

        If ($FileInterfaceID) {

          # Creation of the body hash
          $body = @{}

          If ($PSBoundParameters.ContainsKey('nasServer')) {
            # nasServer argument
            $body["nasServer"] = @{}
            $FileInterfaceArg = @{}
            $FileInterfaceArg["id"] = "$($FileInterface)"
            $body["nasServer"] = $FileInterfaceArg
          }

          If ($PSBoundParameters.ContainsKey('ipPort')) {
            # ipPort argument
            $body["ipPort"] = @{}
            $ipPortArg = @{}
            $ipPortArg["id"] = "$($ipPort)"
            $body["ipPort"] = $ipPortArg
          }

          # ipAddress argument
          If ($PSBoundParameters.ContainsKey('ipAddress')) {
            $body["ipAddress"] = "$ipAddress"
          }

          If ($PSBoundParameters.ContainsKey('netmask')) {
                $body["netmask"] = "$netmask"
          }

          If ($PSBoundParameters.ContainsKey('v6PrefixLength')) {
                $body["v6PrefixLength"] = "$v6PrefixLength"
          }

          If ($PSBoundParameters.ContainsKey('gateway')) {
                $body["gateway"] = "$gateway"
          }

          If ($PSBoundParameters.ContainsKey('vlanId')) {
                $body["vlanId"] = $vlanId
          }

          If ($PSBoundParameters.ContainsKey('isPreferred')) {
                $body["isPreferred"] = $isPreferred
          }

          If ($PSBoundParameters.ContainsKey('replicationPolicy')) {
                $body["replicationPolicy"] = "$($ReplicationPolicyEnum["$($replicationPolicy)"])"
          }

          #Building the URI
          $URI = 'https://'+$sess.Server+'/api/instances/fileInterface/'+$FileInterfaceID+'/action/modify'
          Write-Verbose "URI: $URI"

          #Sending the request
          If ($pscmdlet.ShouldProcess($FileInterfaceID,"Modify File Interface")) {
            $request = Send-UnityRequest -uri $URI -Session $Sess -Method 'POST' -Body $Body
          }

          If ($request.StatusCode -eq '204') {

            Write-Verbose "Pool with ID: $FileInterfaceID has been modified"

            Get-UnityFileInterface -Session $Sess -id $FileInterfaceID

          }
        } else {
          Write-Verbose "NAS Server $FileInterfaceID does not exist on the array $($sess.Name)"
        }
      } else {
        Write-Information -MessageData "You are no longer connected to EMC Unity array: $($Sess.Server)"
      }
    }
  }

  End {}
}

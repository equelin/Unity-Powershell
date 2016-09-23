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
      .PARAMETER Session
      Specify an UnitySession Object.
      .PARAMETER ID
      File interface ID or Object
      .PARAMETER ipPort
      Physical port or link aggregation on the storage processor on which the interface is running
      .PARAMETER ipAddress
      IP address of the network interface
      .PARAMETER netmask
      IPv4 netmask for the network interface, if it uses an IPv4 address
      .PARAMETER v6PrefixLength
      IPv6 prefix length for the interface, if it uses an IPv6 address
      .PARAMETER gateway
      IPv4 or IPv6 gateway address for the network interface
      .PARAMETER vlanId
      LAN identifier for the interface. The interface uses the identifier to accept packets that have matching VLAN tags. Values are 1 - 4094.
      .PARAMETER isPreferred
      Sets the current IP interface as preferred for associated for file-based storage and unsets the previous one
      .PARAMETER replicationPolicy
      Indicates the status of the NAS server object operating as a replication destination
      .PARAMETER Confirm
      If the value is $true, indicates that the cmdlet asks for confirmation before running. 
      If the value is $false, the cmdlet runs without asking for user confirmation.
      .PARAMETER WhatIf
      Indicate that the cmdlet is run only to display the changes that would be made and actually no objects are modified.
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
    [ReplicationPolicyEnum]$replicationPolicy
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"

    # Variables
    $URI = '/api/instances/fileInterface/<id>/action/modify '
    $Type = 'File Interface'
    $TypeName = 'UnityFileInterface'
    $StatusCode = 204
  }

  Process {

    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If ($Sess.TestConnection()) {

        Foreach ($i in $ID) {

          # Determine input and convert to object if necessary
          Switch ($i.GetType().Name)
          {
            "String" {
              $Object = get-UnityFileInterface -Session $Sess -ID $i
              $ObjectID = $Object.id
              If ($Object.Name) {
                $ObjectName = $Object.Name
              } else {
                $ObjectName = $ObjectID
              }
            }
            "$TypeName" {
              Write-Verbose "Input object type is $($i.GetType().Name)"
              $ObjectID = $i.id
              If ($Object = Get-UnityFileInterface -Session $Sess -ID $ObjectID) {
                If ($Object.Name) {
                  $ObjectName = $Object.Name
                } else {
                  $ObjectName = $ObjectID
                }          
              }
            }
          }

          If ($ObjectID) {

            #### REQUEST BODY 

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
                  $body["replicationPolicy"] = "$replicationPolicy"
            }

            ####### END BODY - Do not edit beyond this line

            #Show $body in verbose message
            $Json = $body | ConvertTo-Json -Depth 10
            Write-Verbose $Json 

            #Building the URL
            $FinalURI = $URI -replace '<id>',$ObjectID

            $URL = 'https://'+$sess.Server+$FinalURI
            Write-Verbose "URL: $URL"

            #Sending the request
            If ($pscmdlet.ShouldProcess($Sess.Name,"Modify $Type $ObjectName")) {
              $request = Send-UnityRequest -uri $URL -Session $Sess -Method 'POST' -Body $Body
            }

            If ($request.StatusCode -eq $StatusCode) {

              Write-Verbose "$Type with ID $ObjectID has been modified"

              Get-UnityFileInterface -Session $Sess -id $ObjectID

            }  # End If ($request.StatusCode -eq $StatusCode)
          } else {
            Write-Warning -Message "$Type with ID $i does not exist on the array $($sess.Name)"
          } # End If ($ObjectID)
        } # End Foreach ($i in $ID)
      } # End If ($Sess.TestConnection()) 
    } # End Foreach ($sess in $session)
  } # End Process
} # End Function

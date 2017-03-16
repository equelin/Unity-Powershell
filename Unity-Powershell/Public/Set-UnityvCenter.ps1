Function Set-UnityvCenter {

  <#
      .SYNOPSIS
      Modifies an existing vCenter and optionally discovers any ESXi host managed by that vCenter.
      .DESCRIPTION
      Modifies vCenter servers on the network and optionnaly create a host configuration for multiple ESXi hosts managed by a single vCenter server.
      You can't modify vCenter parameters and import hosts in the same command. 
      For any discovered vCenters, you can enable or disable access for any ESXi host managed by the vCenter.
      After you associate a vCenter server configuration with a VMware datastore, the datastore is available to any ESXi hosts associated with the vCenter host configuration.
      The vCenter credentials are stored in the storage system.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specify an UnitySession Object.
      .PARAMETER ID
      vCenter ID or Object.
      .PARAMETER NewAddress
      The new FQDN or IP address of the VMware vCenter.
      .PARAMETER NewUsername
      Specifies the new username used to access the VMware vCenter.
      .PARAMETER NewPassword
      Specifies the new password used to access the VMware vCenter.
      .PARAMETER Description
      Specifies the new description of the VMware vCenter server.
      .PARAMETER Username
      Specifies the new username used to access the VMware vCenter.
      .PARAMETER Password
      Specifies the new password used to access the VMware vCenter.
      .PARAMETER ImportHosts
      Specifies if hosts are automatically imported.
      .EXAMPLE
      Set-UnityvCenter -ID 'mss_1' -Description 'New description'

      Change the description of the vCenter.

      .EXAMPLE
      Set-UnityvCenter -ID 'mss_1' -Username 'administrator@vsphere.local' -Password 'Password#123' -ImportHosts

      Import hosts associated to the vCenter.
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High',DefaultParameterSetName="Set")]
  Param (
    #Default Parameters
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),

    #vCenter
    [Parameter(Mandatory = $true,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'vCenter ID or Object')]
    $ID,
    [Parameter(Mandatory = $false,ParameterSetName="Set",HelpMessage = 'The new FQDN or IP address of the vCenter server')]
    [String]$NewAddress,
    [Parameter(Mandatory = $false,ParameterSetName="Set",HelpMessage = 'The new user name to access vCenter server')]
    [string]$NewUsername,
    [Parameter(Mandatory = $false,ParameterSetName="Set",HelpMessage = 'The new password to connect to vCenter server')]
    [String]$NewPassword,
    [Parameter(Mandatory = $false,ParameterSetName="Set",HelpMessage = 'The new description of the vCenter server')]
    [String]$Description,
    [Parameter(Mandatory = $true,ParameterSetName="ImportHosts",HelpMessage = 'The user name to access vCenter server')]
    [string]$Username,
    [Parameter(Mandatory = $true,ParameterSetName="ImportHosts",HelpMessage = 'The password to connect to vCenter server')]
    [String]$Password,
    [Parameter(Mandatory = $true,ParameterSetName="ImportHosts",HelpMessage = 'Specifies if hosts are automatically imported')]
    [Switch]$ImportHosts
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      Foreach ($I in $ID) {

        Write-Verbose "Processing ID: $I"

      # Determine input and convert to an object
      Write-Verbose "Input object type is $($I.GetType().Name)"
      Switch ($I.GetType().Name)
      {
        "String" {
          $vCenterServer = get-UnityvCenter -Session $Sess -ID $I
          $vCenterServerID = $vCenterServer.id
        }
        "UnityHostContainer" {
          $vCenterServer = $I
          $vCenterServerID = $ID.id
        }
      }

      If ($vCenterServerID) {

        # Creation of the body hash
        $body = @{}

        Switch ($PsCmdlet.ParameterSetName) {
          'Set' {

            If ($PSBoundParameters.ContainsKey('NewAddress')) {
              $body["targetAddress"] = $NewAddress
            }
            
            If ($PSBoundParameters.ContainsKey('description')) {
              $body["description"] = $Description
            }

            If ($PSBoundParameters.ContainsKey('NewUsername')) {
              $body["username"] = $NewUsername
            }

            If ($PSBoundParameters.ContainsKey('NewPassword')) {
              $body["password"] = $NewPassword
            }

            $Json = $body | ConvertTo-Json -Depth 10

            Write-Verbose $Json 

            If ($Sess.TestConnection()) {

              #Building the URI
              $URI = 'https://'+$sess.Server+'/api/instances/hostContainer/'+$vCenterServerID+'/action/modify'
              Write-Verbose "URI: $URI"

              #Sending the request
              If ($pscmdlet.ShouldProcess($vCenterServerID,"Modify vCenter Server")) {
                $request = Send-UnityRequest -uri $URI -Session $Sess -Method 'POST' -Body $Body
              }

              Write-Verbose "Request status code: $($request.StatusCode)"

              If (($request.StatusCode -eq '200') -or ($request.StatusCode -eq '204')) {

                Write-Verbose "vCenter $vCenterServerID has been modified"

                #Executing Get-UnityUser with the ID of the Set user
                Get-UnityvCenter -Session $Sess -ID $vCenterServerID  
                
              }
            } else {
              Write-Warning "You are no longer connected to EMC Unity array: $($Sess.Server)"
            }
          }
          'ImportHosts' {

            $recommendation = Get-UnityHostContainerReco -Session $Sess -Address $vCenterServer.address -Username $Username -Password $Password

            Foreach ($Host in $recommendation.potentialHosts) {

              $body["potentialHosts"] = @()

              $body["potentialHosts"] += $Host

              $Json = $body | ConvertTo-Json -Depth 10

              Write-Verbose $Json 

              If ($Sess.TestConnection()) {

                #Building the URI
                $URI = 'https://'+$sess.Server+'/api/instances/hostContainer/'+$vCenterServerID+'/action/modify'
                Write-Verbose "URI: $URI"

                #Sending the request
                If ($pscmdlet.ShouldProcess($host.servername,"Add host")) {
                  $request = Send-UnityRequest -uri $URI -Session $Sess -Method 'POST' -Body $Body
                }
                  
              } else {
                Write-Warning "You are no longer connected to EMC Unity array: $($Sess.Server)"
              }
            }

            #Executing Get-UnityUser with the ID of the Set user
            Get-UnityvCenter -Session $Sess -ID $vCenterServerID  

          }
        }
      } else {
        Write-Verbose "vCenter Server does not exist on the array $($sess.Name)"
      }

      }
    }
  }

  End {}
}

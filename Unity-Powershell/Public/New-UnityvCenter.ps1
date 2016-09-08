Function New-UnityvCenter {

  <#
      .SYNOPSIS
      Add the vCenter credentials and optionally discovers any ESXi host managed by that vCenter.
      .DESCRIPTION
      Discover vCenter servers on the network and optionnaly create a host configuration for multiple ESXi hosts managed by a single vCenter server. For any discovered vCenters, you can enable or disable access for any ESXi host managed by the vCenter. After you associate a vCenter server configuration with a VMware datastore, the datastore is available to any ESXi hosts associated with the vCenter host configuration.
      The vCenter credentials are stored in the storage system.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specify an UnitySession Object.
      .PARAMETER Address
      FQDN or IP address of the VMware vCenter.
      .PARAMETER Username
      Specifies the username used to access the VMware vCenter.
      .PARAMETER Password
      Specifies the password used to access the VMware vCenter.
      .PARAMETER Description
      Specifies the description of the VMware vCenter server.
      .PARAMETER ImportHosts
      Specifies if hosts are automatically imported.
      .EXAMPLE
      New-UnityvCenter -Address 'vcenter.example.com' -Username 'admin' -Password 'Password123#' -ImportHosts

      Import a vCenter and all the associated ESXi hosts.
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    #Default Parameters
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),

    #vCenter
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'The IP address of the vCenter server')]
    [String[]]$Address,
    [Parameter(Mandatory = $true,HelpMessage = 'The user name to access vCenter server')]
    [string]$Username,
    [Parameter(Mandatory = $true,HelpMessage = 'The password to connect to vCenter server')]
    [String]$Password,
    [Parameter(Mandatory = $false,HelpMessage = 'Description of the vCenter server')]
    [String]$Description,
    [Parameter(Mandatory = $false,HelpMessage = 'Specifies if hosts are automatically imported')]
    [Switch]$ImportHosts
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"

    # Variables
    $URI = '/api/types/hostContainer/instances'
    $Type = 'vCenter'
    $StatusCode = 201
  }

  Process {
    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      #### REQUEST BODY 

      Foreach ($a in $Address) {

        $recommendation = Get-UnityHostContainerReco  -Session $Sess -Address $a -Username $Username -Password $Password

        # Creation of the body hash
        $body = @{}

        # serviceType parameter
        $body["serviceType"] = "$($recommendation.type)"

        # targetName parameter
        $body["targetName"] = "$($recommendation.containerName)"

        # targetAddress parameter
        $body["targetAddress"] = "$a"

        # username parameter
        $body["username"] = "$Username"

        # password parameter
        $body["password"] = "$Password"

        If ($PSBoundParameters.ContainsKey('description')) {
          $body["description"] = $Description
        }

        If ($PSBoundParameters.ContainsKey('ImportHosts')) {
          $body["potentialHosts"] = $recommendation.potentialHosts | Where-Object {$_.importOption -ne 2}
        }

        ####### END BODY - Do not edit beyond this line

        #Show $body in verbose message
        $Json = $body | ConvertTo-Json -Depth 10
        Write-Verbose $Json  

        If ($Sess.TestConnection()) {

          ##Building the URL
          $URL = 'https://'+$sess.Server+$URI
          Write-Verbose "URL: $URL"

          #Sending the request
          If ($pscmdlet.ShouldProcess($Sess.Name,"Create $Type $a")) {
            $request = Send-UnityRequest -uri $URL -Session $Sess -Method 'POST' -Body $Body
          }

          Write-Verbose "Request status code: $($request.StatusCode)"

          If ($request.StatusCode -eq $StatusCode) {

            #Formating the result. Converting it from JSON to a Powershell object
            $results = ($request.content | ConvertFrom-Json).content

            Write-Verbose "$Type with the ID $($results.id) has been created"

            Get-UnityvCenter -Session $Sess -ID $results.id  
          } # End If ($request.StatusCode -eq $StatusCode)
        } # End If ($Sess.TestConnection()) 
      } # End Foreach
    } # End Foreach ($sess in $session)
  } # End Process
} # End Function

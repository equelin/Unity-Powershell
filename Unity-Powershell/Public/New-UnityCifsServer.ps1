Function New-UnityCIFSServer {

  <#
      .SYNOPSIS
      Creates a pool.
      .DESCRIPTION
      Creates a pool.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .EXAMPLE
      New-UnityCifsServer -nasServer 'nas_1' -Name 'CIFS01'

      Create CIFS Server named 'CIFS01'
  #>

  [CmdletBinding(DefaultParameterSetName="AD")]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,Position = 1,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Pool Name')]
    [String[]]$Name,
    [Parameter(Mandatory = $true,HelpMessage = 'ID of the NAS server to which the SMB server belongs')]
    [String]$nasServer,
    [Parameter(Mandatory = $false,HelpMessage = 'Description of the SMB server')]
    [String]$Description,
    [Parameter(Mandatory = $false,ParameterSetName="AD",HelpMessage = 'Domain name where SMB server is registered in Active Directory, if applicable.')]
    [String]$domain,
    [Parameter(Mandatory = $false,ParameterSetName="AD",HelpMessage = 'LDAP organizational unit of SMB server in Active Directory, if applicable')]
    [String]$organizationalUnit,
    [Parameter(Mandatory = $false,ParameterSetName="AD",HelpMessage = 'Active Directory domain user name')]
    [String]$domainUsername,
    [Parameter(Mandatory = $false,ParameterSetName="AD",HelpMessage = 'Active Directory domain password')]
    [String]$domainPassword,
    [Parameter(Mandatory = $false,ParameterSetName="AD",HelpMessage = 'Reuse existing SMB server account in the Active Directory')]
    [Bool]$reuseComputerAccount,
    [Parameter(Mandatory = $false,ParameterSetName="Workgroup",HelpMessage = 'Standalone SMB server workgroup name')]
    [String]$workgroup,
    [Parameter(Mandatory = $false,ParameterSetName="Workgroup",HelpMessage = 'Is Snapshot Harvest Enabled')]
    [String]$localAdminPassword,
    [Parameter(Mandatory = $false,HelpMessage = 'List of file IP interfaces that service CIFS protocol of SMB server')]
    [String[]]$interfaces
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"

    #Initialazing arrays
    $ResultCollection = @()
  }

  Process {
    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      Foreach ($n in $Name) {

        # Creation of the body hash
        $body = @{}

        # nasServer argument
        $body["nasServer"] = @{}
        $nasServerArg = @{}
        $nasServerArg["id"] = "$($nasServer)"
        $body["nasServer"] = $nasServerArg

        # netbiosName argument
        If ($PSBoundParameters.ContainsKey('netbiosName')) {
              $body["netbiosName"] = "$($netbiosName)"
        }

        # Name argument
        If ($PSBoundParameters.ContainsKey('Name')) {
              $body["name"] = "$($name)"
        }

        # Description argument
        If ($PSBoundParameters.ContainsKey('description')) {
              $body["description"] = "$($description)"
        }

        # domain argument
        If ($PSBoundParameters.ContainsKey('domain')) {
              $body["domain"] = "$($domain)"
        }

        # organizationalUnit argument
        If ($PSBoundParameters.ContainsKey('organizationalUnit')) {
              $body["organizationalUnit"] = "$($organizationalUnit)"
        }

        # domainUsername argument
        If ($PSBoundParameters.ContainsKey('domainUsername')) {
              $body["domainUsername"] = "$($domainUsername)"
        }

        # domainPassword argument
        If ($PSBoundParameters.ContainsKey('domainPassword')) {
              $body["domainPassword"] = "$($domainPassword)"
        }

        # reuseComputerAccount argument
        If ($PSBoundParameters.ContainsKey('reuseComputerAccount')) {
              $body["reuseComputerAccount"] = $reuseComputerAccount
        }

        # workgroup argument
        If ($PSBoundParameters.ContainsKey('workgroup')) {
              $body["workgroup"] = "$($workgroup)"
        }

        # localAdminPassword argument
        If ($PSBoundParameters.ContainsKey('localAdminPassword')) {
              $body["localAdminPassword"] = "$($localAdminPassword)"
        }

        #interfaces argument
        $body['interfaces'] = @()
        Foreach ($int in $interfaces) {
          $ÎntArgument = @{}
          $ÎntArgument['id'] = "$($int)"
          $body["interfaces"] += $ÎntArgument
        }

        If ($Sess.TestConnection()) {

          #Building the URI
          $URI = 'https://'+$sess.Server+'/api/types/cifsServer/instances'
          Write-Verbose "URI: $URI"

          #Sending the request
          $request = Send-UnityRequest -uri $URI -Session $Sess -Method 'POST' -Body $Body

          Write-Verbose "Request status code: $($request.StatusCode)"

          If ($request.StatusCode -eq '201') {

            #Formating the result. Converting it from JSON to a Powershell object
            $results = ($request.content | ConvertFrom-Json).content

            Write-Verbose "CIFS Server created with the ID: $($results.id) "

            #Executing Get-UnityUser with the ID of the new user
            Get-UnityCifsServer -Session $Sess -ID $results.id
          }
        } else {
          Write-Information -MessageData "You are no longer connected to EMC Unity array: $($Sess.Server)"
        }
      }
    }
  }

  End {}
}

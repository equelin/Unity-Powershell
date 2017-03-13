Function New-UnityCIFSServer {

  <#
      .SYNOPSIS
      Create an SMB/CIFS server.
      .DESCRIPTION
      Create an SMB/CIFS server.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specify an UnitySession Object.
      .PARAMETER nasServer
      ID of the NAS server to which the SMB server belongs.
      .PARAMETER netbiosName
      Computer name of the SMB server in Windows network.
      .PARAMETER name
      User friendly, descriptive name of SMB server.
      .PARAMETER description
      Description of the SMB server.
      .PARAMETER domain
      Domain name where SMB server is registered in Active Directory, if applicable.
      .PARAMETER organizationalUnit
      LDAP organizational unit of SMB server in Active Directory, if applicable.
      .PARAMETER domainUsername
      Active Directory domain user name.
      .PARAMETER domainPassword
      Active Directory domain password.
      .PARAMETER reuseComputerAccount
      Reuse existing SMB server account in the Active Directory.
      .PARAMETER workgroup
      Standalone SMB server workgroup.
      .PARAMETER localAdminPassword
      Standalone SMB server administrator password.
      .PARAMETER interfaces
      List of file IP interfaces that service CIFS protocol of SMB server.
      .PARAMETER Confirm
      If the value is $true, indicates that the cmdlet asks for confirmation before running. If the value is $false, the cmdlet runs without asking for user confirmation.
      .PARAMETER WhatIf
      Indicate that the cmdlet is run only to display the changes that would be made and actually no objects are modified.
      .EXAMPLE
      New-UnityCIFSServer -Name CIFS01 -nasServer 'nas_6' -domain 'example.com' -domainUsername 'administrator' -domainPassword 'Password#123' -interfaces 'if_1'

      Create CIFS Server named 'CIFS01'
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High',DefaultParameterSetName="AD")]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,Position = 1,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'User friendly, descriptive name of SMB server')]
    [String[]]$Name,
    [Parameter(Mandatory = $true,HelpMessage = 'ID of the NAS server to which the SMB server belongs')]
    [String]$nasServer,
    [Parameter(Mandatory = $false,HelpMessage = 'Computer name of the SMB server in Windows network')]
    [String]$netbiosName,
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
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    ## Variables
    $URI = '/api/types/cifsServer/instances'
    $Type = 'Server CIFS'
    $StatusCode = 201
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      Foreach ($n in $Name) {

        #### REQUEST BODY 

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
        If ($PSBoundParameters.ContainsKey('interfaces')) {
          $body['interfaces'] = @()
          Foreach ($int in $interfaces) {
            $ÎntArgument = @{}
            $ÎntArgument['id'] = "$($int)"
            $body["interfaces"] += $ÎntArgument
          }
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
          If ($pscmdlet.ShouldProcess($Sess.Name,"Create $Type $n")) {
            $request = Send-UnityRequest -uri $URL -Session $Sess -Method 'POST' -Body $Body
          }

          Write-Verbose "Request status code: $($request.StatusCode)"

          If ($request.StatusCode -eq $StatusCode) {

            #Formating the result. Converting it from JSON to a Powershell object
            $results = ($request.content | ConvertFrom-Json).content

            Write-Verbose "$Type with the ID $($results.id) has been created"

            Get-UnityCifsServer -Session $Sess -ID $results.id
          } # End If ($request.StatusCode -eq $StatusCode)
        } # End If ($Sess.TestConnection()) 
      } # End Foreach
    } # End Foreach ($sess in $session)
  } # End Process
} # End Function

Function Connect-Unity {

  <#
      .SYNOPSIS
      Connects to an EMC Unity Array
      .DESCRIPTION
      Connects to an EMC Unity Array. This cmdlet starts a new session with an EMC Unity Array using the specified parameters.
      When you attempt to connect to an array, the array checks for valid certificates. To avoid this use the -TrusAllCerts param.
      You can have more than one connection to the same array. To disconnect from an array, you need to close all active connections to this server using the Disconnect-Unity cmdlet.
      Every new connection is stored in the $global:DefaultUnitySession array.
      .NOTES
      Written by Erwan Quelin under Apache licence
      .LINK
      https://github.com/equelin/Unity-Powershell
      .EXAMPLE
      Connect-Unity -Server 192.168.0.1 -TrustAllCerts

      Connects to the array with the IP 192.168.0.1 and accept unknown certificates.
      .EXAMPLE
      Connect-Unity -Server 192.168.0.1,192.168.0.2

      Connects to the array with the IP 192.168.0.1 and 192.168.0.2
  #>

  [CmdletBinding(DefaultParameterSetName="ByServer")]
  Param(
      [Parameter(Mandatory = $true,Position = 0,ParameterSetName="ByServer",ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'EMC Unity FQDN or IP address')]
      [String]$Server,
      [Parameter(Mandatory = $true,Position = 0,ParameterSetName="BySession",ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'EMC Unity Session object')]
      [UnitySession]$Session,
      [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity username')]
      [String]$Username,
      [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity password')]
      [SecureString]$Password,
      [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity credentials')]
      [System.Management.Automation.CredentialAttribute()]$Credentials,
      [Parameter(Mandatory = $false,HelpMessage = 'Trust all certs ?')]
      [Bool]$TrustAllCerts = $True
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"
    if ($TrustAllCerts) {
      Unblock-UnityCerts
    }
  }

  Process {

    If ($PsCmdlet.ParameterSetName -eq 'BySession') {
      Write-Verbose -Message "Disconnect or delete previous session"
      Disconnect-Unity -Session $Session -Confirm:$False

      Write-Verbose -Message "Server: $($Session.Server)"
      $Server = $Session.Server
    }

    Write-Verbose -Message 'Validating that login details were passed into username/password or credentials'
    if ($Password -eq $null -and $Credentials -eq $null)
    {
        Write-Verbose -Message 'Missing username, password, or credentials.'
        $Credentials = Get-Credential -Message 'Please enter administrative credentials for your EMC Unity Array'
    }

    if ($Credentials -eq $null)
    {
        $Credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username, $Password
    }

    #Encoding username and password for HTTP Basic authentication
    $EncodedAuthorization = [System.Text.Encoding]::UTF8.GetBytes($Credentials.username + ':' + $Credentials.GetNetworkCredential().Password)
    $EncodedPassword = [System.Convert]::ToBase64String($EncodedAuthorization)

    #Initialazing Cookies Container
    $Cookies = New-Object -TypeName System.Net.CookieContainer

    $result = Get-UnityAuth -Server $server -EncodedPassword $EncodedPassword -Cookies $Cookies

    #Building the UnitySession Object
    $Sess = New-Object -TypeName UnitySession
    $Sess.IsConnected = $true
    $Sess.Server = $Server
    $Sess.Headers = $result['Headers']
    $Sess.Cookies = $result['Cookies']
    $Sess.SessionId = ([guid]::NewGuid())
    $Sess.User = $Credentials.username

    $System = Get-UnitySystem -Session $Sess

    $Sess.Name = $System.Name
    $Sess.Model = $System.model
    $Sess.SerialNumber = $System.SerialNumber

    #Add the UnitySession Object to the $global:DefaultUnitySession array
    $global:DefaultUnitySession += $Sess

    #Return the new session
    Write-Output $Sess
  }

  End {}

}

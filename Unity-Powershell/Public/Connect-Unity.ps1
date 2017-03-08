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
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specifies an UnitySession Object.
      .PARAMETER Server
      IP or FQDN of the Unity array.
      .PARAMETER Username
      Specifies the username.
      .PARAMETER Password
      Specifies the password. It as to be a powershell's secure string.
      .PARAMETER Credentials
      Credentials object of type [System.Management.Automation.PSCredential]
      .PARAMETER TrustAllCerts
      Specifies if
      .EXAMPLE
      Connect-Unity -Server 192.168.0.1

      Connects to the array with the IP 192.168.0.1
      .EXAMPLE
      Connect-Unity -Server 192.168.0.1 -TrustAllCerts $false

      Connects to the array with the IP 192.168.0.1 and don't accept unknown certificates.
      .EXAMPLE
      Connect-Unity -Server 192.168.0.1,192.168.0.2

      Connects to the arrays with the IP 192.168.0.1 and 192.168.0.2. The same user and password is used.
      .EXAMPLE
      $IP = '192.168.0.1'
      $Username = 'admin'
      $Password = 'Password123#'
      $Secpasswd = ConvertTo-SecureString $Password -AsPlainText -Force
      $Credentials = New-Object System.Management.Automation.PSCredential($Username,$secpasswd)
      Connect-Unity -Server $IP -Credentials $Credentials

      Connects to the arrays with the IP 192.168.0.1 and using powershell credentials
  #>

  [CmdletBinding(DefaultParameterSetName="ByServer")]
  Param(
      [Parameter(Mandatory = $true,Position = 0,ParameterSetName="ByServer",ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'EMC Unity FQDN or IP address')]
      [String[]]$Server,
      [Parameter(Mandatory = $true,ParameterSetName="BySession",ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'EMC Unity Session object')]
      $Session,
      [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity username')]
      [String]$Username,
      [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity password')]
      [SecureString]$Password,
      [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity credentials')]
      [PSCredential]$Credentials,
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
      Try {
        $Credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username, $Password
      }
      Catch {
        throw
      }
    }

    #Encoding username and password for HTTP Basic authentication
    $EncodedAuthorization = [System.Text.Encoding]::UTF8.GetBytes($Credentials.username + ':' + $Credentials.GetNetworkCredential().Password)
    $EncodedPassword = [System.Convert]::ToBase64String($EncodedAuthorization)


    foreach ($srv in $Server) {
      #Initializing Cookies Container
      $Cookies = New-Object -TypeName System.Net.CookieContainer

      $result = Get-UnityAuth -Server $srv -EncodedPassword $EncodedPassword -Cookies $Cookies

      #Building the UnitySession Object
      $Sess = New-Object -TypeName UnitySession
      $Sess.IsConnected = $true
      $Sess.Server = $srv
      $Sess.Headers = $result['Headers']
      $Sess.Cookies = $result['Cookies']
      $Sess.SessionId = ([guid]::NewGuid())
      $Sess.User = $Credentials.username

      #Initialazing Websession variable
      $Websession = New-Object Microsoft.PowerShell.Commands.WebRequestSession

      #Add session's cookies to Websession
      Foreach ($cookie in $sess.Cookies) {
        Write-Verbose "Add cookie: $($cookie.Name) to WebSession"
        $Websession.Cookies.Add($cookie);
      }
      $Sess.Websession = $Websession

      # Get types definitions from API
      $Types = Get-UnityItem -URI '/api/types' -Session $Sess
      $Sess.Types = $Types.entries.content | where-object {$_.name -notlike '*Enum'}

      # Get informations about the array
      $System = Get-UnitySystem -Session $Sess
      $BasicSystemInfo = Get-UnityBasicSystemInfo -Session $Sess
      $Sess.Name = $System.Name
      $Sess.Model = $System.model
      $Sess.SerialNumber = $System.SerialNumber
      $Sess.ApiVersion = $BasicSystemInfo.ApiVersion

      #Add the UnitySession Object to the $global:DefaultUnitySession array
      $global:DefaultUnitySession += $Sess

      #Return the new session
      Write-Output $Sess
    }


  }

  End {
    ## update the Windows PowerShell titlebar with a bit of info about the Unity array(s) to which the PowerShell session is connected
    Update-TitleBarForUnityConnection
  }

}

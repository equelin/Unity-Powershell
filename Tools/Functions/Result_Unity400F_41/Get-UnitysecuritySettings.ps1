Function Get-UnitysecuritySettings {

  <#
      .SYNOPSIS
      All the system level security settings. <br/> Use this resource to enable and disable system level security settings. <br/> The settings include: <br/> <br/> a) FIPS 140-2 <br/> Information about whether the system is working in Federal Information Processing Standard (FIPS) 140-2 mode. <br/> <br/> The storage systems support FIPS 140-2 mode for the RSA BSAFE SSL modules on the storage pocessor that handle client management traffic. Management communication into and out of the system is encrypted using SSL. As a part of this process, the client and the Storage Management Server negotiate a cipher suite to use in the exchange. The use of FIPS 140-2 mode restricts the allowable set of cipher suites that can be selected in the negotiation to those that are sufficiently strong. <br/> <br/> If FIPS 140-2 mode is enabled, you may find that some of your existing clients can no longer communicate with the management ports of the array if they do not support a cipher suite of acceptable strength. <br/> <br/> b) SSO <br/> Information about whether the system is participating in Single Sign On mode. <br/> <br/> In Single Sign On (SSO) mode, Unisphere Central (UC) becomes the authentication server for multiple storage system, thus creating a shared authentication domain where cross-array operations can be performed without re-entering user credentials. <br/> <br/> If SSO is enabled, the system will participate in Single Sign On mode, and authenticate against Unisphere Central previously configured on this array. <br/> <br/> c) TLS 1.0 <br/> Information about whether the Storage Management Server allows SSL communication using the TLS 1.0 protocol. <br/> <br/> Management communication into and out of the Storage Management Server is encrypted using SSL. As a part of this process, the client and the Storage Management Server negotiate a SSL protocol to use. By default, the Storage Management Server supports TLS 1.0, TLS 1.1 and TLS 1.2 protocols for SSL communications. Disabling the TLS 1.0 protocol using this setting means that the Storage Management Server will only support SSL communications using the TLS 1.1 and TLS 1.2 protocols and TLS 1.0 will not be considered a valid protocol. <br/> <br/> Disabling TLS 1.0 may impact existing client applications which are not compatible with TLS 1.1 or TLS 1.2 protocols. In this case, TLS 1.0 support should remain enabled. <br/> <br/>  
      .DESCRIPTION
      All the system level security settings. <br/> Use this resource to enable and disable system level security settings. <br/> The settings include: <br/> <br/> a) FIPS 140-2 <br/> Information about whether the system is working in Federal Information Processing Standard (FIPS) 140-2 mode. <br/> <br/> The storage systems support FIPS 140-2 mode for the RSA BSAFE SSL modules on the storage pocessor that handle client management traffic. Management communication into and out of the system is encrypted using SSL. As a part of this process, the client and the Storage Management Server negotiate a cipher suite to use in the exchange. The use of FIPS 140-2 mode restricts the allowable set of cipher suites that can be selected in the negotiation to those that are sufficiently strong. <br/> <br/> If FIPS 140-2 mode is enabled, you may find that some of your existing clients can no longer communicate with the management ports of the array if they do not support a cipher suite of acceptable strength. <br/> <br/> b) SSO <br/> Information about whether the system is participating in Single Sign On mode. <br/> <br/> In Single Sign On (SSO) mode, Unisphere Central (UC) becomes the authentication server for multiple storage system, thus creating a shared authentication domain where cross-array operations can be performed without re-entering user credentials. <br/> <br/> If SSO is enabled, the system will participate in Single Sign On mode, and authenticate against Unisphere Central previously configured on this array. <br/> <br/> c) TLS 1.0 <br/> Information about whether the Storage Management Server allows SSL communication using the TLS 1.0 protocol. <br/> <br/> Management communication into and out of the Storage Management Server is encrypted using SSL. As a part of this process, the client and the Storage Management Server negotiate a SSL protocol to use. By default, the Storage Management Server supports TLS 1.0, TLS 1.1 and TLS 1.2 protocols for SSL communications. Disabling the TLS 1.0 protocol using this setting means that the Storage Management Server will only support SSL communications using the TLS 1.1 and TLS 1.2 protocols and TLS 1.0 will not be considered a valid protocol. <br/> <br/> Disabling TLS 1.0 may impact existing client applications which are not compatible with TLS 1.1 or TLS 1.2 protocols. In this case, TLS 1.0 support should remain enabled. <br/> <br/>  
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
      Get-UnitysecuritySettings

      Retrieve information about all UnitysecuritySettings
      .EXAMPLE
      Get-UnitysecuritySettings -ID 'id01'

      Retrieves information about a specific UnitysecuritySettings
  #>

  [CmdletBinding(DefaultParameterSetName='Name')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName='ID',ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'UnitysecuritySettings ID')]
    [String[]]$ID
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    #Initialazing variables
    $URI = '/api/types/securitySettings/instances' #URI
    $TypeName = 'UnitysecuritySettings'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "[$($MyInvocation.MyCommand)] Processing Session: $($Session.Server) with SessionId: $($Session.SessionId)"

      Get-UnityItemByKey -Session $Sess -URI $URI -Typename $Typename -Key $PsCmdlet.ParameterSetName -Value $PSBoundParameters[$PsCmdlet.ParameterSetName]

    } # End Foreach ($sess in $session)
  } # End Process
} # End Function


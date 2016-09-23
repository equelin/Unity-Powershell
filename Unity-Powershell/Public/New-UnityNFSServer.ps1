Function New-UnityNFSServer { 

  <#
      .SYNOPSIS
      Create a new NFS Server. 
      .DESCRIPTION
      Create a new NFS Server. 
      You need to have an active session with the array. 
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session 
      Specify an UnitySession Object.
      .PARAMETER Confirm 
      If the value is $true, indicates that the cmdlet asks for confirmation before running. If the value is $false, the cmdlet runs without asking for user confirmation.
      .PARAMETER WhatIf
      Indicate that the cmdlet is run only to display the changes that would be made and actually no objects are modified.
      .EXAMPLE 
      New-UnityNFSServer -address 'smtp.example.com' -type 'default' 

      Create a new default NFS Server.
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),

    #ID of the NAS server associated with the NFS server.
    [Parameter(Mandatory = $true,HelpMessage = 'ID of the NAS server associated with the NFS server.')]
    [string]$nasServer,

    #Host name of the NFS server. If host name is not specified then SMB server name or NAS server name will be used to auto generate the host name.
    [Parameter(Mandatory = $false,HelpMessage = 'Host name of the NFS server. If host name is not specified then SMB server name or NAS server name will be used to auto generate the host name.')]
    [string]$hostName,

    #Indicates whether the NFSv4 is enabled on the NAS server specified in the nasServer attribute.
    [Parameter(Mandatory = $false,HelpMessage = 'Indicates whether the NFSv4 is enabled on the NAS server specified in the nasServer attribute.')]
    [bool]$nfsv4Enabled,

    #Indicates whether the secure NFS is enabled. 
    [Parameter(Mandatory = $false,HelpMessage = 'Indicates whether the secure NFS is enabled.')]
    [bool]$isSecureEnabled,

    #Type of Kerberos Domain Controller used for secure NFS service.
    [Parameter(Mandatory = $false,HelpMessage = 'Type of Kerberos Domain Controller used for secure NFS service.')]
    [KdcTypeEnum]$kdcType,

    #Kerberos Domain Controller administrator's name.
    [Parameter(Mandatory = $false,HelpMessage = 'Kerberos Domain Controller administrator s name.')]
    [string]$kdcUsername,

    #Kerberos Domain Controller administrator's password.
    [Parameter(Mandatory = $false,HelpMessage = 'Kerberos Domain Controller administrator s password.')]
    [string]$kdcPassword,

    #Support for more than 16 Unix groups.
    [Parameter(Mandatory = $false,HelpMessage = 'Support for more than 16 Unix groups.')]
    [bool]$isExtendedCredentialsEnabled,

    #Credential cache refresh timeout. Resolution is in minutes. 
    #Default value is 15 minutes.
    [Parameter(Mandatory = $false,HelpMessage = 'Credential cache refresh timeout. Resolution is in minutes.')]
    [DateTime]$credentialsCacheTTL
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"

    ## Variables
    $URI = '/api/types/nfsServer/instances' 
    $Item = 'NFS Server' 
    $StatusCode = 201 
  }

  Process {
    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      #### REQUEST BODY 


      #Creation of the body hash
      $body = @{}

      #Body arguments

      $body["nasServer"] = @{}

      $nasServerParameters = @{}
        $nasServerParameters["id"] = $nasServer
      $body["nasServer"] = $nasServerParameters

      If ($PSBoundParameters.ContainsKey('hostName')) {
            $body["hostName"] = "$hostName"
      }

      If ($PSBoundParameters.ContainsKey('isReplicationDestination')) {
            $body["isReplicationDestination"] = $isReplicationDestination
      }

      If ($PSBoundParameters.ContainsKey('nfsv4Enabled')) {
            $body["nfsv4Enabled"] = $nfsv4Enabled
      }

      If ($PSBoundParameters.ContainsKey('isSecureEnabled')) {
            $body["isSecureEnabled"] = $isSecureEnabled
      }

      If ($PSBoundParameters.ContainsKey('kdcType')) {
            $body["kdcType"] = "$kdcType"
      }

      If ($PSBoundParameters.ContainsKey('kdcUsername')) {
            $body["kdcUsername"] = "$kdcUsername"
      }

      If ($PSBoundParameters.ContainsKey('kdcPassword')) {
            $body["kdcPassword"] = "$kdcPassword"
      }

      If ($PSBoundParameters.ContainsKey('isExtendedCredentialsEnabled')) {
            $body["isExtendedCredentialsEnabled"] = $isExtendedCredentialsEnabled
      }

      If ($PSBoundParameters.ContainsKey('credentialsCacheTTL')) {
            $body["credentialsCacheTTL"] = $credentialsCacheTTL
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
          If ($pscmdlet.ShouldProcess($Sess.Name,"Create $Item $address")) {
            $request = Send-UnityRequest -uri $URL -Session $Sess -Method 'POST' -Body $Body
          }

          Write-Verbose "Request status code: $($request.StatusCode)"

          If ($request.StatusCode -eq $StatusCode) {

            #Formating the result. Converting it from JSON to a Powershell object
            $results = ($request.content | ConvertFrom-Json).content

            Write-Verbose "$Item with the ID $($results.id) has been created"

          #Executing Get-UnityUser with the ID of the new user
          Get-UnityNFSServer -Session $Sess -ID $results.id
        } # End If ($request.StatusCode -eq $StatusCode)
      } # End If ($Sess.TestConnection()) 
    } # End Foreach ($sess in $session)
  } # End Process
} # End Function

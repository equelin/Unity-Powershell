Function Set-UnityNFSServer {

  <#
      .SYNOPSIS
      Modifies NFS Server.
      .DESCRIPTION
      Modifies NFS Server.
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
      Set-UnityNFSServer -ID 'default' -Address smtp.example.com

      Modifies the default NFS Server
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    #Default Parameters
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),

    #NFS Server ID or Object.
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'NFS Server ID or Object.')] 
    [Object[]]$ID, 

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

    #Keep Service Principal Name (SPN) in Kerberos Domain Controller.
    [Parameter(Mandatory = $true,HelpMessage = 'Keep Service Principal Name (SPN) in Kerberos Domain Controller.')]
    [switch]$skipUnjoin,

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
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    # Variables
    $URI = '/api/instances/nfsServer/<id>/action/modify' 
    $Type = 'NFS Server' 
    $TypeName = 'UnityNfsServer' 
    $StatusCode = 204 
  }

  Process {

    Foreach ($sess in $session) {

      Write-Debug -Message "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If ($Sess.TestConnection()) {

        Foreach ($i in $ID) {

          # Determine input and convert to object if necessary
          $Object,$ObjectID,$ObjectName = Get-UnityObject -Data $i -Typename $Typename -Session $Sess

          If ($ObjectID) {

            #### REQUEST BODY

            # Creation of the body hash
            $body = @{}

            If ($PSBoundParameters.ContainsKey('hostName')) {
                  $body["hostName"] = $hostName
            }

            If ($PSBoundParameters.ContainsKey('nfsv4Enabled')) {
                  $body["nfsv4Enabled"] = $nfsv4Enabled
            }

            If ($PSBoundParameters.ContainsKey('isSecureEnabled')) {
                  $body["isSecureEnabled"] = $isSecureEnabled
            }

            If ($PSBoundParameters.ContainsKey('kdcType')) {
                  $body["kdcType"] = $kdcType
            }

            If ($PSBoundParameters.ContainsKey('skipUnjoin')) {
                  $body["skipUnjoin"] = $skipUnjoin
            }

            If ($PSBoundParameters.ContainsKey('kdcUsername')) {
                  $body["kdcUsername"] = $kdcUsername
            }

            If ($PSBoundParameters.ContainsKey('kdcPassword')) {
                  $body["kdcPassword"] = $kdcPassword
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

              Get-UnityNFSServer -Session $Sess -id $ObjectID

            }  # End If ($request.StatusCode -eq $StatusCode)
          } else {
            Write-Warning -Message "$Type with ID $i does not exist on the array $($sess.Name)"
          } # End If ($ObjectID)
        } # End Foreach ($i in $ID)
      } # End If ($Sess.TestConnection()) 
    } # End Foreach ($sess in $session)
  } # End Process
} # End Function

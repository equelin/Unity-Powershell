Function Set-UnityFileDnsServer {

  <#
      .SYNOPSIS
      Modifies File DNS Server parameters.
      .DESCRIPTION
      Modifies File DNS Server parameters.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specify an UnitySession Object.
      .PARAMETER ID
      File DNS Server ID or Object
      .PARAMETER domain
      DNS domain name
      .PARAMETER addresses
      The list of DNS server IP addresses
      .PARAMETER replicationPolicy
      Status of the LDAP list in the NAS server operating as a replication destination.
      .EXAMPLE
      Set-UnityFileDnsServer -ID 'dns_1' -ipAddress '192.168.0.1'

      Change ip of the file DNS server with ID 'dns_1'
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'File DNS Server ID or Object')]
    $ID,
    [Parameter(Mandatory = $false,HelpMessage = 'DNS domain name')]
    [string]$domain,
    [Parameter(Mandatory = $false,HelpMessage = 'The list of DNS server IP addresses')]
    [String[]]$addresses,
    [Parameter(Mandatory = $false,HelpMessage = 'Status of the LDAP list in the NAS server operating as a replication destination.')]
    [ReplicationPolicyEnum]$replicationPolicy
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"

    # Variables
    $URI = '/api/instances/fileDNSServer/<id>/action/modify'
    $Type = 'File DNS Server'
    $TypeName = 'UnityFileDnsServer'
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
              $Object = get-UnityFileDnsServer -Session $Sess -ID $i
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
              If ($Object = Get-UnityFileDnsServer -Session $Sess -ID $ObjectID) {
                If ($Object.Name) {
                  $ObjectName = $Object.Name
                } else {
                  $ObjectName = $ObjectID
                }          
              }
            }
          }

          If ($ObjectID) {

            # Creation of the body hash
            $body = @{}

            #Addresses argument
            $body['addresses'] = @()
            Foreach ($Addresse in $Addresses) {
              $body["addresses"] += $Addresse
            }

            If ($PSBoundParameters.ContainsKey('domain')) {
                  $body["domain"] = "$($domain)"
            }

            If ($PSBoundParameters.ContainsKey('replicationPolicy')) {
                  $body["replicationPolicy"] = $replicationPolicy
            }

            ####### END BODY - Do not edit beyond this line

            #Show $body in verbose message
            $Json = $body | ConvertTo-Json -Depth 10
            Write-Verbose $Json 

            #Building the URL
            $URI = $URI -replace '<id>',$ObjectID

            $URL = 'https://'+$sess.Server+$URI
            Write-Verbose "URL: $URL"

            #Sending the request
            If ($pscmdlet.ShouldProcess($Sess.Name,"Modify $Type $ObjectName")) {
              $request = Send-UnityRequest -uri $URL -Session $Sess -Method 'POST' -Body $Body
            }

            If ($request.StatusCode -eq $StatusCode) {

              Write-Verbose "$Type with ID $ObjectID has been modified"

              Get-UnityFileDnsServer -Session $Sess -id $ObjectID

            }  # End If ($request.StatusCode -eq $StatusCode)
          } else {
            Write-Warning -Message "$Type with ID $i does not exist on the array $($sess.Name)"
          } # End If ($ObjectID)
        } # End Foreach ($i in $ID)
      } # End If ($Sess.TestConnection()) 
    } # End Foreach ($sess in $session)
  } # End Process
} # End Function

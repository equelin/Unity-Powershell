Function Set-UnityMgmtInterface {

  <#
      .SYNOPSIS
      Modify settings for an management interface. 
      .DESCRIPTION
      Modify settings for an management interface.  
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specify an UnitySession Object.
      .PARAMETER ID
      Management interface ID or Object.
      .PARAMETER ipAddress
      IPv4 or IPv6 address for the interface.
      .PARAMETER netmask
      IPv4 netmask for the interface, if the interface uses an IPv4 address.
      .PARAMETER v6PrefixLength
      Prefix length in bits for IPv6 address.
      .PARAMETER gateway
      IPv4 or IPv6 gateway address for the interface.
      .PARAMETER Confirm
      If the value is $true, indicates that the cmdlet asks for confirmation before running. If the value is $false, the cmdlet runs without asking for user confirmation.
      .PARAMETER WhatIf
      Indicate that the cmdlet is run only to display the changes that would be made and actually no objects are modified.
      .EXAMPLE
      Set-UnityMgmtInterface -ID 'mgmt_ipv4' -gateway '192.0.2.254'

      Change gateway of the management interface with ID 'mgmt_ipv4'
  #>

    [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Management interface ID or Object')]
    [String[]]$ID,
    [Parameter(Mandatory = $false,Position = 1,HelpMessage = 'IPv4 or IPv6 address for the interface.')]
    [string]$ipAddress,
    [Parameter(Mandatory = $false,HelpMessage = 'IPv4 netmask for the interface, if the interface uses an IPv4 address.')]
    [string]$netmask,
    [Parameter(Mandatory = $false,HelpMessage = 'Prefix length in bits for IPv6 address.')]
    [String[]]$v6PrefixLength,
    [Parameter(Mandatory = $false,Position = 1,HelpMessage = 'IPv4 or IPv6 gateway address for the interface.')]
    [string]$gateway
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    # Variables
    $URI = '/api/instances/mgmtInterface/<id>/action/modify'
    $Type = 'Management Interface'
    $TypeName = 'UnityMgmtInterface'
    $StatusCode = 204
  }

  Process {

    Foreach ($sess in $session) {

      Foreach ($i in $ID) {

        Write-Debug -Message "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

        If ($Sess.TestConnection()) {

            # Determine input and convert to object if necessary
            Switch ($i.GetType().Name)
            {
              "String" {
                $Object = get-UnityMgmtInterface -Session $Sess -ID $i
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
                If ($Object = Get-UnityMgmtInterface -Session $Sess -ID $ObjectID) {
                  If ($Object.Name) {
                    $ObjectName = $Object.Name
                  } else {
                    $ObjectName = $ObjectID
                  }          
                }
              }
            }

          If ($ObjectID) {

            #### REQUEST BODY 

            # Creation of the body hash
            $body = @{}

            # ipAddress argument
            If ($PSBoundParameters.ContainsKey('ipAddress')) {
              $body["ipAddress"] = "$ipAddress"
            }

            If ($PSBoundParameters.ContainsKey('netmask')) {
              $body["netmask"] = "$netmask"
            }

            If ($PSBoundParameters.ContainsKey('v6PrefixLength')) {
              $body["v6PrefixLength"] = "$v6PrefixLength"
            }

            If ($PSBoundParameters.ContainsKey('gateway')) {
              $body["gateway"] = "$gateway"
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

              Get-UnityMgmtInterface -Session $Sess -id $ObjectID

            }  # End If ($request.StatusCode -eq $StatusCode)
          } else {
            Write-Warning -Message "$Type with ID $i does not exist on the array $($sess.Name)"
          } # End If ($ObjectID)
        } # End Foreach ($i in $ID)
      } # End If ($Sess.TestConnection()) 
    } # End Foreach ($sess in $session)
  } # End Process
} # End Function

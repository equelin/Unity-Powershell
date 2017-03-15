Function Set-UnityHostIPPort {

  <#
      .SYNOPSIS
      Modify a host IP Port configuration. 
      .DESCRIPTION
      Modify a host IP Port configuration. 
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specify an UnitySession Object.
      .PARAMETER Confirm
      If the value is $true, indicates that the cmdlet asks for confirmation before running. 
      If the value is $false, the cmdlet runs without asking for Host IP Port confirmation.
      .PARAMETER WhatIf
      Indicate that the cmdlet is run only to display the changes that would be made and actually no objects are modified.
      .EXAMPLE
      Set-UnityHostIPPort -ID 'HostNetworkAddress_47' -address '192.168.0.1'

      Change the IP of the host.
      .EXAMPLE
      Get-UnityHostIPPort -ID 'HostNetworkAddress_47' | Set-UnityHostIPPort -address '192.168.0.1'

      Gives the role 'operator' to the Host IP Port 'Host'. The Host's information are provided by the Get-UnityHostIPPort through the pipeline.
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    
    #Host IP Port ID or Object
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Host IP Port ID or Object')]
    $ID,

    #IP address or network name of the port.
    [Parameter(Mandatory = $false,HelpMessage = 'IP address or network name of the port.')]
    [string]$address,

    #(Applies to IPV4 only.) Subnet mask for the IP address, if any.
    [Parameter(Mandatory = $false,HelpMessage = '(Applies to IPV4 only.) Subnet mask for the IP address, if any.')]
    [string]$netmask,

    #(Applies to IPV6 only.) Subnet mask length.
    [Parameter(Mandatory = $false,HelpMessage = '(Applies to IPV6 only.) Subnet mask length.')]
    [string]$v6PrefixLength,

    #(Applies to NFS access only.) Indicates whether the port should be ignored when storage access is granted to the host
    [Parameter(Mandatory = $false,HelpMessage = '(Applies to NFS access only.) Indicates whether the port should be ignored when storage access is granted to the host')]
    [bool]$isIgnored
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    # Variables
    $URI = '/api/instances/hostIPPort/<id>/action/modify'
    $Type = 'Host IP Port'
    $TypeName = 'UnityHostIPPort'
    $StatusCode = 204
  }

  Process {

    Foreach ($sess in $session) {

      Write-Debug -Message "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If ($Sess.TestConnection()) {

        Foreach ($i in $ID) {

          # Determine input and convert to object if necessary
          Switch ($i.GetType().Name)
          {
            "String" {
              $Object = get-UnityHostIPPort -Session $Sess -ID $i
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
              If ($Object = Get-UnityHostIPPort -Session $Sess -ID $ObjectID) {
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

            If ($PSBoundParameters.ContainsKey('address')) {
                  $body["address"] = $address
            }

            If ($PSBoundParameters.ContainsKey('netmask')) {
                  $body["netmask"] = $netmask
            }

            If ($PSBoundParameters.ContainsKey('v6PrefixLength')) {
                  $body["v6PrefixLength"] = $v6PrefixLength
            }

            If ($PSBoundParameters.ContainsKey('isIgnored')) {
                  $body["isIgnored"] = $isIgnored
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

              Get-UnityHostIPPort -Session $Sess -id $ObjectID

            }  # End If ($request.StatusCode -eq $StatusCode)
          } else {
            Write-Warning -Message "$Type with ID $i does not exist on the array $($sess.Name)"
          } # End If ($ObjectID)
        } # End Foreach ($i in $ID)
      } # End If ($Sess.TestConnection()) 
    } # End Foreach ($sess in $session)
  } # End Process
} # End Function

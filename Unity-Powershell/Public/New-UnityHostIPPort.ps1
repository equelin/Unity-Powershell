Function New-UnityHostIPPort {

  <#
      .SYNOPSIS
       Create a host IP Port configuration. 
      .DESCRIPTION
       Create a host IP Port configuration. 
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
      New-UnityHostIPPort -host 'Host_1' - address 192.0.2.1 -netmask 255.255.255.0

      Create Host IP Port for the host with ID 'Host_1'.
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    #Default Parameters
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),

    #Host ID or Object
    [Parameter(Mandatory = $true,Position = 1,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Host ID or Object')]
    $host,

    #IP address or network name of the port.
    [Parameter(Mandatory = $true,HelpMessage = 'IP address or network name of the port.')]
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

    ## Variables
    $URI = '/api/types/hostIPPort/instances'
    $Type = 'Host IP Port'
    $TypeName = 'UnityHost'
    $StatusCode = 201
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      Foreach ($h in $Host) {

        # Determine input and convert to object if necessary
        Switch ($h.GetType().Name)
        {
          "String" {
            $Object = get-UnityHost -Session $Sess -ID $h
            $ObjectID = $Object.id
            If ($Object.Name) {
              $ObjectName = $Object.Name
            } else {
              $ObjectName = $ObjectID
            }
          }
          "$TypeName" {
            Write-Verbose "Input object type is $($h.GetType().Name)"
            $ObjectID = $h.id
            If ($Object = Get-UnityHost -Session $Sess -ID $ObjectID) {
              If ($Object.Name) {
                $ObjectName = $Object.Name
              } else {
                $ObjectName = $ObjectID
              }          
            }
          }
        } # End Switch

        If ($ObjectID) {

          #### REQUEST BODY 

          # Creation of the body hash
          $body = @{}

          $body["host"] = @{}
            $hostParameters = @{}
            $hostParameters["id"] = $ObjectID
          $body["host"] = $hostParameters

          # address parameter
          $body["address"] = $address

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

              Get-UnityHostIPPort -Session $Sess -ID $results.id
            } else {
            Write-Warning -Message "$Type with ID $i does not exist on the array $($sess.Name)"
            } # End If ($ObjectID)
          } # End If ($request.StatusCode -eq $StatusCode)
        } # End If ($Sess.TestConnection()) 
      } # End Foreach
    } # End Foreach ($sess in $session)
  } # End Process
} # End Function
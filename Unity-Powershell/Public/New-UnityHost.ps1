Function New-UnityHost {

  <#
      .SYNOPSIS
       Create a host configuration. 
      .DESCRIPTION
       Create a host configuration. 
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
      New-UnityHost -Name 'Host01'

      Create Host named 'Host01'.
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    #Default Parameters
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),

    #Host Name
    [Parameter(Mandatory = $true,Position = 1,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Host Name')]
    [String[]]$Name,

    #Type of host configuration.
    [Parameter(Mandatory = $false,HelpMessage = 'Type of host configuration.')]
    [HostTypeEnum]$type='HostManual',

    #Host Description
    [Parameter(Mandatory = $false,HelpMessage = 'Host Description')]
    [String]$Description,

    #Operating system running on the host.
    [Parameter(Mandatory = $false,HelpMessage = 'Operating system running on the host.')]
    [string]$osType
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"

    ## Variables
    $URI = '/api/types/host/instances'
    $TypeName = 'Host'
    $StatusCode = 201
  }

  Process {
    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      Foreach ($n in $Name) {

        #### REQUEST BODY 

        # Creation of the body hash
        $body = @{}

        # Name parameter
        $body["name"] = $n

        # type parameter
        $body["type"] = $type

        If ($PSBoundParameters.ContainsKey('description')) {
              $body["description"] = $description
        }

        If ($PSBoundParameters.ContainsKey('osType')) {
              $body["osType"] = $osType
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
          If ($pscmdlet.ShouldProcess($Sess.Name,"Create $TypeName $n")) {
            $request = Send-UnityRequest -uri $URL -Session $Sess -Method 'POST' -Body $Body
          }

          Write-Verbose "Request status code: $($request.StatusCode)"

          If ($request.StatusCode -eq $StatusCode) {

            #Formating the result. Converting it from JSON to a Powershell object
            $results = ($request.content | ConvertFrom-Json).content

            Write-Verbose "$TypeName with the ID $($results.id) has been created"

            Get-UnityHost -Session $Sess -ID $results.id
          } # End If ($request.StatusCode -eq $StatusCode)
        } # End If ($Sess.TestConnection()) 
      } # End Foreach
    } # End Foreach ($sess in $session)
  } # End Process
} # End Function
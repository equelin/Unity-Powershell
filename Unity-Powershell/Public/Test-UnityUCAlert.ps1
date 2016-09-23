Function Test-UnityUCAlert {

  <#
      .SYNOPSIS
      Test Unisphere Central alert notification by sending a test alert to a Unisphere Central destination. 
      .DESCRIPTION
      Test Unisphere Central alert notification by sending a test alert to a Unisphere Central destination. 
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specify an UnitySession Object.
      .PARAMETER ID
      ID or Object of a Alert Config..
      .EXAMPLE
      Test-UnityUCAlert

      Test Unisphere Central alert notification by sending a test alert to a Unisphere Central destination.
  #>

  [CmdletBinding(DefaultParameterSetName="Refresh")]
  Param (
    #Default Parameters
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),

    [Parameter(Mandatory = $false,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'ID or Object of Alert Config')]
    [String[]]$ID = '0'
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"

    # Variables
    $URI = '/api/instances/alertConfig/<id>/action/testUCAlert'
    $Type = 'Alert'
    $StatusCode = 204
  }

  Process {
    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If ($Sess.TestConnection()) {

      Foreach ($i in $ID) {

        Switch ($i.GetType().Name)
        {
          "String" {
            $Object = get-UnityAlertConfig -Session $Sess -ID $i
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
            If ($Object = Get-UnityAlertConfig -Session $Sess -ID $ObjectID) {
              If ($Object.Name) {
                $ObjectName = $Object.Name
              } else {
                $ObjectName = $ObjectID
              }          
            }
          }
        }

        If ($ObjectID) {

            #Building the URL
            $FinalURI = $URI -replace '<id>',$ObjectID

            $URL = 'https://'+$sess.Server+$FinalURI
            Write-Verbose "URL: $URL"

            #Sending the request
            $request = Send-UnityRequest -uri $URL -Session $Sess -Method 'POST'

            If ($request.StatusCode -eq $StatusCode) {

                Write-Host "$Type send to the Unisphere Central"
              
              }  # End If ($request.StatusCode -eq $StatusCode)
            } else {
            Write-Warning -Message "$Type with ID $i does not exist on the array $($sess.Name)"
          } # End If ($ObjectID)
        } # End Foreach ($i in $ID)
      } # End If ($Sess.TestConnection()) 
    } # End Foreach ($sess in $session)
  } # End Process
} # End Function

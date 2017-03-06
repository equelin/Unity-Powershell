Function Get-UnityHostInitiator {

  <#
      .SYNOPSIS
      View details about host initiators.
      .DESCRIPTION
      View details about host initiators on the system.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quélin under MIT licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specifies an UnitySession Object.
      .PARAMETER ID
      Specifies the object ID.
      .PARAMETER PortWWN
      Specifies the port WWN.
      .EXAMPLE
      Get-UnityHostInitiator

      Retrieve information about all hosts

      .EXAMPLE
      Get-UnityHostInitiator -ID 'Host_67'

      Retrieves information about host initiator named 'Host_67'
  #>

  [CmdletBinding(DefaultParameterSetName="ByID")]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName="ByID",ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Host Initiator ID')]
    [String[]]$ID='*',
    [Parameter(Mandatory = $false,ParameterSetName="ByPortWwn",ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Initiator Port WWN')]
    [String[]]$PortWWN='*'    
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"

    #Initialazing variables
    $ResultCollection = @()
    $URI = '/api/types/hostInitiator/instances' #URI
    $TypeName = 'UnityHostInitiator'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If ($Sess.TestConnection()) {

        #Building the URL from Object Type.
        $URL = Get-URLFromObjectType -Session $sess -URI $URI -TypeName $TypeName -Compact

        Write-Verbose "URL: $URL"

        #Sending the request
        $request = Send-UnityRequest -uri $URL -Session $Sess -Method 'GET'

        #Formating the result. Converting it from JSON to a Powershell object
        $Results = ($request.content | ConvertFrom-Json).entries.content

        #Building the result collection (Add ressource type)
        If ($Results) {

          $ResultsFiltered = @()
          
          # Results filtering
          Switch ($PsCmdlet.ParameterSetName) {
            'ById' {
              $ResultsFiltered += Find-FromFilter -Parameter 'ID' -Filter $ID -Data $Results
            }
            'ByPortWwn' {
              $ResultsFiltered += Find-FromFilter -Parameter 'PortWWN' -Filter $PortWWN -Data $Results
            }
          }

          If ($ResultsFiltered) {
            
            $ResultCollection = ConvertTo-Hashtable -Data $ResultsFiltered

            Foreach ($Result in $ResultCollection) {

              $object = $null
              # Instantiate object
              try
              {
                $Object = New-Object -TypeName $TypeName -Property $Result
                
              }
              catch
              {
                throw $_
              }

              # Output results
              $Object
            } # End Foreach ($Result in $ResultCollection)
          } # End If ($ResultsFiltered) 
        } # End If ($Results)
      } # End If ($Sess.TestConnection()) 
    } # End Foreach ($sess in $session)
  } # End Process
} # End Function
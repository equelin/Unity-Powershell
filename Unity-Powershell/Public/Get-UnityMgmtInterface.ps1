Function Get-UnityMgmtInterface {

  <#
      .SYNOPSIS
      Information about management interfaces in the storage system. 
      .DESCRIPTION
      Information about management interfaces in the storage system. 
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
      Get-UnityMgmtInterface

      Retrieve informations about all the management interface.
  #>

  [CmdletBinding(DefaultParameterSetName="ByID")]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName="ByID",ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'File DNS Server ID')]
    [String[]]$ID='*'
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"

    #Initialazing variables
    $ResultCollection = @()
    $URI = '/api/types/mgmtInterface/instances' #URI for the ressource (example: /api/types/lun/instances)
    $TypeName = 'UnityMgmtInterface'
  }

  Process {
    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If ($Sess.TestConnection()) {

        #Building the URL from Object Type.
        $URL = Get-URLFromObjectType -Server $sess.Server -URI $URI -TypeName $TypeName -Compact

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
            'ByID' {
              $ResultsFiltered += Find-FromFilter -Parameter 'ID' -Filter $ID -Data $Results
            }
          }

          If ($ResultsFiltered) {
            
            $ResultCollection = ConvertTo-Hashtable -Data $ResultsFiltered

            Foreach ($Result in $ResultCollection) {

              # Instantiate object
              $Object = New-Object -TypeName $TypeName -Property $Result

              # Output results
              $Object
            }
          }
        }
      } else {
        Write-Host "You are no longer connected to EMC Unity array: $($Sess.Server)"
      }
    }
  }
}

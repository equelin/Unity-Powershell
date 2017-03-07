Function Get-UnitystorageResource {

  <#
      .SYNOPSIS
      Queries the EMC Unity array to retrieve informations about UnitystorageResource.
      .DESCRIPTION
      Querries the EMC Unity array to retrieve informations about UnitystorageResource.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under MIT licence
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specifies an UnitySession Object.
      .PARAMETER Name
      Specifies the object name.
      .PARAMETER ID
      Specifies the object ID.
      .PARAMETER Type
      Specifies the storage ressource type. Might be:
      - lun
      - vmwareiscsi
      - vmwarefs
      .EXAMPLE
      Get-UnitystorageResource

      Retrieve informations about all the storage ressources
      .EXAMPLE
      Get-UnitystorageResource -Name 'DATASTORE01'

      Retrieves informations about storage ressource named DATASTORE01
  #>

  [CmdletBinding(DefaultParameterSetName="ByName")]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ParameterSetName="ByName",ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Storage Resource Name')]
    [String[]]$Name='*',
    [Parameter(Mandatory = $false,ParameterSetName="ByID",ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Storage Resource ID')]
    [String[]]$ID='*',
    [Parameter(Mandatory = $false,HelpMessage = 'Storage ressource type')]
    [ValidateSet('lun','vmwareiscsi','vmwarefs')]
    [String]$Type
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"

    #Initialazing variables
    $ResultCollection = @()
    $URI = '/api/types/storageResource/instances' #URI for the ressource (example: /api/types/lun/instances)
    $TypeName = 'UnitystorageResource'

    Switch ($Type) {
      'lun' {$Filter = 'type eq 8'}
      'vmwareiscsi' {$Filter = 'type eq 4'}
      'vmwarefs' {$Filter = 'type eq 3'}
    }
  }

  Process { 
    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If ($Sess.TestConnection()) {

        #Building the URL from Object Type.
        $URL = Get-URLFromObjectType -Session $sess -URI $URI -TypeName $TypeName -Filter $Filter -Compact

        Write-Verbose "URL: $URL"

        #Sending the request
        $request = Send-UnityRequest -uri $URL -Session $Sess -Method 'GET'

        #Formating the result. Converting it from JSON to a Powershell object
        $results = ($request.content | ConvertFrom-Json).entries.content

        #Building the result collection (Add ressource type)
        If ($Results) {

          $ResultsFiltered = @()
          
          # Results filtering
          Switch ($PsCmdlet.ParameterSetName) {
            'ByName' {
              $ResultsFiltered += Find-FromFilter -Parameter 'Name' -Filter $Name -Data $Results
            }
            'ByID' {
              $ResultsFiltered += Find-FromFilter -Parameter 'ID' -Filter $ID -Data $Results
            }
          }

          If ($ResultsFiltered) {
            
            $ResultCollection = ConvertTo-Hashtable -Data $ResultsFiltered

            Foreach ($Result in $ResultCollection) {

              # Instantiate object
              $Object = New-Object -TypeName $TypeName -Property $Result

              # Convert to MB
              #$Object.ConvertToMB()

              # Output results
              $Object
            } # End Foreach ($Result in $ResultCollection)
          } # End If ($ResultsFiltered) 
        } # End If ($Results)
      } # End If ($Sess.TestConnection()) 
    } # End Foreach ($sess in $session)
  } # End Process
} # End Function

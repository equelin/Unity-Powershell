<#
    .SYNOPSIS
#>

Function Get-UnityItemByKey {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True,HelpMessage = 'EMC Unity Session')]
        $session,
        [Parameter(Mandatory = $True,HelpMessage = 'URI')]
        [String]$URI,
        [Parameter(Mandatory = $True,HelpMessage = 'Typename')]
        [String]$Typename,
        [Parameter(Mandatory = $True,HelpMessage = 'Key')]
        [String]$Key,
        [Parameter(Mandatory = $False,HelpMessage = 'Value')]
        [String[]]$Value,
        [parameter(Mandatory = $False, HelpMessage = 'Ressource Filter')]
        [string]$Filter
    )

    Begin {
        Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"
    }

    Process {

      If ($Session.TestConnection()) {

        #Building the URL from Object Type.
        If ($Filter) {
            $URL = Get-URLFromObjectType -Session $Session -URI $URI -TypeName $TypeName -Compact -Filter $Filter
        } else {
            $URL = Get-URLFromObjectType -Session $Session -URI $URI -TypeName $TypeName -Compact
        }
        
        Write-Debug -Message "[$($MyInvocation.MyCommand)] URL: $URL"

        #Sending the request
        $request = Send-UnityRequest -uri $URL -Session $Session -Method 'GET'

        #Formating the result. Converting it from JSON to a Powershell object
        $Results = ($request.content | ConvertFrom-Json).entries.content

        #Building the result collection (Add ressource type)
        If ($Results) {

            $ResultsFiltered = @()

            If (-not $Value) {
                $Value = '*'
            }
          
            # Results filtering
            $ResultsFiltered += Find-FromFilter -Parameter $Key -Filter $Value -Data $Results

            If ($ResultsFiltered) {
            
                $ResultCollection = ConvertTo-Hashtable -Data $ResultsFiltered

                Foreach ($Result in $ResultCollection) {

                    # Instantiate and output object
                    New-Object -TypeName $TypeName -Property $Result

                } # End Foreach ($Result in $ResultCollection)
            } # End If ($ResultsFiltered) 
        } else {
            Write-Error -Message "Object(s) not found" -Category ObjectNotFound
        } # End If ($Results)
    } # End If ($Sess.TestConnection())

  }
    
}
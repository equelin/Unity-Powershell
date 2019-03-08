Function New-UnityTreeQuota {

  <#
      .SYNOPSIS
      Creates a Unity TreeQuota.
      .DESCRIPTION
      Creates a Unity TreeQuota.
      You need to have an active session with the array.
      .LINK
      https://github.com/equelin/Unity-Powershell
      .PARAMETER Session
      Specify an UnitySession Object.
      .PARAMETER Fylesystem
      Fylesystem Id where create the TreeQuota
      .PARAMETER Path
      TreeQuota Path
      .PARAMETER Description
      TreeQuota Description
      .PARAMETER HardLimit
      TreeQuota hard limit
      .PARAMETER SoftLimit
      TreeQuota soft limit

      .EXAMPLE
      New-UnityTreeQuota -Fylesystem 'fs_1' -Path '/Path' -Description 'First TreeQuota' -HardLimit 10GB -SoftLimit 5GB 

      Create a TreeQuota over the Path '/Path' on filesystem 'fs_1' with a soft limit of 5GB amd a hard limit of 10GB
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    
    #Default Parameters
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),

    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'TreeQuotaPath')]
    [String[]]$Path,
    [Parameter(Mandatory = $true,HelpMessage = 'Filesystem ID')]
    [String]$Filesystem,

    [Parameter(Mandatory = $false,HelpMessage = 'TreeQuota Description')]
    [String]$Description,
    [Parameter(Mandatory = $false,HelpMessage = 'TreeQuota hard limit')]
    [uint64]$HardLimit,
    [Parameter(Mandatory = $false,HelpMessage = 'TreeQuota soft limit')]
    [uint64]$SoftLimit
    
  )

  Begin {
    Write-Debug -Message "[$($MyInvocation.MyCommand)] Executing function"

    ## Variables
    $URI = '/api/types/treeQuota/instances'
    $Type = 'treeQuota'
    $StatusCode = 201
  }

  Process {
    Foreach ($sess in $session) {

      Write-Debug -Message "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      Foreach ($n in $Path) {

        #### REQUEST BODY 

        # Creation of the body hash
        $body = @{}

        # Path parameter
        $body["path"] = "$($n)"

        # Filesystem parameter
        $body["filesystem"] = @{}
        $filesystemArg = @{}
        $filesystemArg["id"] = "$($Filesystem)"
        $body["filesystem"] = $filesystemArg

        # Optional parameters
        If ($Description) {
              $body["description"] = "$($Description)"
        }

        If ($HardLimit) {
              $body["hardLimit"] = "$($HardLimit)"
        }

        If ($SoftLimit) {
              $body["softLimit"] = "$($SoftLimit)"
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

            Get-UnityTreeQuota -session $Sess -ID $results.id
          } # End If ($request.StatusCode -eq $StatusCode)
        } # End If ($Sess.TestConnection()) 
      } # End Foreach
    } # End Foreach ($sess in $session)
  } # End Process
} # End Function

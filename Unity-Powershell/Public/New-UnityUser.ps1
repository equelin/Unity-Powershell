Function New-UnityUser {

  <#
      .SYNOPSIS
      Create a new local user.
      .DESCRIPTION
      Create a new local user and specified role and password.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under Apache licence
      .LINK
      https://github.com/equelin/Unity-Powershell
      .EXAMPLE
      New-UnityUser -Name 'user' -Role 'operator' -Password 'Password@123'

      Creates a new local user named 'User' with the role 'operator' and the password 'Password@123'
  #>

  [CmdletBinding()]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $true,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'User Name')]
    [String[]]$Name,
    [Parameter(Mandatory = $true,HelpMessage = 'User role. It mights be administrator, storageadmin, vmadmin or operator')]
    [String]$Role,
    [Parameter(Mandatory = $true,HelpMessage = 'User Password')]
    [String]$Password
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"

    #Initialazing arrays
    $ResultCollection = @()
  }

  Process {
    Foreach ($n in $Name) {

      # Creation of the body hash
      $body = @{}

      # Name parameter
      $body["name"] = "$($n)"

      # Role parameter
      $body["role"] = "$($Role)"

      # Password parameter
      $body["password"] = "$($Password)"

      Foreach ($sess in $session) {

        Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

        If (Test-UnityConnection -Session $Sess) {

          #Building the URI
          $URI = 'https://'+$sess.Server+'/api/types/user/instances'
          Write-Verbose "URI: $URI"

          #Sending the request
          $request = Send-UnityRequest -uri $URI -Session $Sess -Method 'POST' -Body $Body

          If ($request.StatusCode -eq '201') {

            #Formating the result. Converting it from JSON to a Powershell object
            $results = ($request.content | ConvertFrom-Json).content

            Write-Verbose "User created with the ID: $($results.id) "

            #Executing Get-UnityUser with the ID of the new user
            Get-UnityUser -ID $results.id
          }
        } else {
          Write-Host "You are no longer connected to EMC Unity array: $($Sess.Server)"
        }
      }
    }
  }

  End {
  }
}

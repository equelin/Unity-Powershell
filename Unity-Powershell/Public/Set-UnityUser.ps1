Function Set-UnityUser {

  <#
      .SYNOPSIS
      Modifies local user parameters.
      .DESCRIPTION
      Modifies local user parameters.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under Apache licence
      .LINK
      https://github.com/equelin/Unity-Powershell
      .EXAMPLE
      Set-UnityUser -Name 'User' -Role 'operator'

      Gives the role 'operator' to the user 'User'
      .EXAMPLE
      Get-UnityUSer -Name 'User' | Set-UnityUser -Role 'operator'

      Gives the role 'operator' to the user 'User'. The user's information are provided by the Get-UnityUser through the pipeline.
  #>

  [CmdletBinding()]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'User Name or User Object')]
    $Name,
    [Parameter(Mandatory = $false,HelpMessage = 'User role. It mights be administrator, storageadmin, vmadmin or operator')]
    [String]$Role,
    [Parameter(Mandatory = $false,HelpMessage = 'User Password')]
    [String]$Password,
    [Parameter(Mandatory = $false,HelpMessage = 'User Password')]
    [String]$oldPassword
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"
  }

  Process {
    Foreach ($n in $Name) {

      Write-Verbose "Data type is $($n.GetType().Name)"

      If ($n.GetType().Name -eq 'UnityUser') {
        Write-Verbose "Name is $($n.Name)"
        Write-Verbose "ID is $($n.id)"

        $id = $n.id

      } else {
        $id = (get-UnityUser -Name $n).id
      }

      # Creation of the body hash
      $body = @{}

      # Role parameter
      $body["id"] = "$($id)"

      # role parameter
      If ($Role) {
        $body["role"] = "$($Role)"
      }

      # oldPassword parameter
      If ($password -and $oldPassword) {
        $body["oldPassword"] = "$($oldPassword)"
        $body["password"] = "$($password)"
      }

      Foreach ($sess in $session) {

        Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

        If (Test-UnityConnection -Session $Sess) {

          #Building the URI
          $URI = 'https://'+$sess.Server+'/api/instances/user/'+$id+'/action/modify'
          Write-Verbose "URI: $URI"

          #Sending the request
          $request = Send-UnityRequest -uri $URI -Session $Sess -Method 'POST' -Body $Body

          If ($request.StatusCode -eq '204') {

            Write-Verbose "User with ID: $id as been modified"

            Get-UnityUser -id $id

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

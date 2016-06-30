Function Set-UnityUser {

  <#
      .SYNOPSIS
      Modifies local user parameters.
      .DESCRIPTION
      Modifies local user parameters.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under Apache licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .EXAMPLE
      Set-UnityUser -Name 'User' -Role 'operator'

      Gives the role 'operator' to the user 'User'
      .EXAMPLE
      Get-UnityUSer -Name 'User' | Set-UnityUser -Role 'operator'

      Gives the role 'operator' to the user 'User'. The user's information are provided by the Get-UnityUser through the pipeline.
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'User Name or User Object')]
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

    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If (Test-UnityConnection -Session $Sess) {

        Foreach ($n in $Name) {

          # Determine input and convert to UnityUser object
          Switch ($n.GetType().Name)
          {
            "String" {
              $User = get-UnityUser -Session $Sess -Name $n
              $UserID = $User.id
              $UserName = $n
            }
            "UnityUser" {
              Write-Verbose "Input object type is $($n.GetType().Name)"
              $UserName = $n.Name
              If (Get-UnityUser -Session $Sess -Name $n.Name) {
                        $UserID = $n.id
              }
            }
          }

          If ($UserID) {
            # Creation of the body hash
            $body = @{}

            # Role parameter
            $body["id"] = "$($UserID)"

            # role parameter
            If ($Role) {
              $body["role"] = "$($Role)"
            }

            # oldPassword parameter
            If ($password -and $oldPassword) {
              $body["oldPassword"] = "$($oldPassword)"
              $body["password"] = "$($password)"
            }

            #Building the URI
            $URI = 'https://'+$sess.Server+'/api/instances/user/'+$UserID+'/action/modify'
            Write-Verbose "URI: $URI"

            #Sending the request
            If ($pscmdlet.ShouldProcess($UserName,"Modify User")) {
              $request = Send-UnityRequest -uri $URI -Session $Sess -Method 'POST' -Body $Body
            }

            If ($request.StatusCode -eq '204') {

              Write-Verbose "User with ID: $id has been modified"

              Get-UnityUser -Session $Sess -id $UserID

            }
          } else {
            Write-Information -MessageData "User $UserName does not exist on the array $($sess.Name)"
          }
        }
      } else {
        Write-Information -MessageData "You are no longer connected to EMC Unity array: $($Sess.Server)"
      }
    }
  }

  End {
  }
}

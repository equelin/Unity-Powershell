Function Remove-UnityUser {

  <#
      .SYNOPSIS
      Delete a local user.
      .DESCRIPTION
      Delete a local user.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under Apache licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .EXAMPLE
      Remove-UnityUser -Name 'User'

      Delete the user named 'user'
      .EXAMPLE
      Get-UnityUSer -Name 'User' | Remove-UnityUser

      Delete the user named 'user'. The user's information are provided by the Get-UnityUser through the pipeline.
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'User Name or User Object')]
    $Name
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"
  }

  Process {

    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If ($Sess.TestConnection()) {

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
              If ($User = Get-UnityUser -Session $Sess -Name $UserName) {
                        $UserID = $User.id
              }
            }
          }

          If ($UserID) {

            #Building the URI
            $URI = 'https://'+$sess.Server+'/api/instances/user/'+$UserID
            Write-Verbose "URI: $URI"

            if ($pscmdlet.ShouldProcess($UserName,"Delete user")) {
              #Sending the request
              $request = Send-UnityRequest -uri $URI -Session $Sess -Method 'DELETE'
            }

            If ($request.StatusCode -eq '204') {

              Write-Verbose "User with ID: $id has been deleted"

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

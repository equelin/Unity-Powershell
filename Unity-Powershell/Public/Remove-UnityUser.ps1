Function Remove-UnityUser {

  <#
      .SYNOPSIS
      Delete a local user.
      .DESCRIPTION
      Delete a local user.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under Apache licence
      .LINK
      https://github.com/equelin/Unity-Powershell
      .EXAMPLE
      Remove-UnityUser -Name 'User'

      Delete the user named 'user'
      .EXAMPLE
      Remove-UnityUSer -Name 'User' | Remove-UnityUser

      Delete the user named 'user'. The user's information are provided by the Get-UnityUser through the pipeline.
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'User Name or User Object')]
    $Name
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

      Foreach ($sess in $session) {

        Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

        If (Test-UnityConnection -Session $Sess) {

          #Building the URI
          $URI = 'https://'+$sess.Server+'/api/instances/user/'+$id
          Write-Verbose "URI: $URI"

          if ($pscmdlet.ShouldProcess($id,"Delete user")) {
            #Sending the request
            $request = Send-UnityRequest -uri $URI -Session $Sess -Method 'DELETE'
          }

          If ($request.StatusCode -eq '204') {

            Write-Verbose "User with ID: $id as been deleted"

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

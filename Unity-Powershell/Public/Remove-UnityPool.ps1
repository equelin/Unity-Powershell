Function Remove-UnityPool {

  <#
      .SYNOPSIS
      Delete a LUN.
      .DESCRIPTION
      Delete a LUN.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under Apache licence - https://github.com/equelin/Unity-Powershell/blob/master/LICENSE
      .LINK
      https://github.com/equelin/Unity-Powershell
      .EXAMPLE
      Remove-UnityPool -Name 'POOL01'

      Delete the pool named 'POOL01'
      .EXAMPLE
      Get-UnityPool -Name 'POOL01' | Remove-UnityPool

      Delete the pool named 'POOL01'. The pool's informations are provided by the Get-UnityPool through the pipeline.
  #>

    [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Pool Name or Pool Object')]
    $Name
  )

  Begin {
    Write-Verbose "Executing function: $($MyInvocation.MyCommand)"
  }

  Process {

    Foreach ($sess in $session) {

      Write-Verbose "Processing Session: $($sess.Server) with SessionId: $($sess.SessionId)"

      If (Test-UnityConnection -Session $Sess) {

        Foreach ($n in $Name) {

          # Determine input and convert to UnityPool object
          Switch ($n.GetType().Name)
          {
            "String" {
              $Pool = get-UnityPool -Session $Sess -Name $n
              $PoolID = $Pool.id
              $PoolName = $Pool.Name
            }
            "UnityPool" {
              Write-Verbose "Input object type is $($n.GetType().Name)"
              $PoolName = $n.Name
              If ($Pool = Get-UnityPool -Session $Sess -Name $PoolName) {
                        $PoolID = $n.id
              }
            }
          }

          If ($PoolID) {
            #Building the URI
            $URI = 'https://'+$sess.Server+'/api/instances/pool/'+$PoolID
            Write-Verbose "URI: $URI"

            if ($pscmdlet.ShouldProcess($PoolName,"Delete pool")) {
              #Sending the request
              $request = Send-UnityRequest -uri $URI -Session $Sess -Method 'DELETE'
            }

            If ($request.StatusCode -eq '204') {

              Write-Verbose "Pool with ID: $id has been deleted"

            }
          } else {
            Write-Information -MessageData "LUN $PoolName does not exist on the array $($sess.Name)"
          }
        }
      } else {
        Write-Information -MessageData "You are no longer connected to EMC Unity array: $($Sess.Server)"
      }
    }
  }

  End {}
}

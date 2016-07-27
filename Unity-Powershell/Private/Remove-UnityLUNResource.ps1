Function Remove-UnityLUNResource {

  <#
      .SYNOPSIS
      Delete a LUN.
      .DESCRIPTION
      Delete a LUN ressource (LUN, VMWare VMFS LUN, VMware NFS LUN).
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under Apache licence
      .LINK
      https://github.com/equelin/Unity-Powershell
      .EXAMPLE
      Remove-UnityLUNResource -Name 'LUN01'

      Delete the LUN named 'LUN01'
      .EXAMPLE
      Get-UnityLUNResource -Name 'LUN01' | Remove-UnityLUNResource

      Delete the LUN named 'LUN01'. The LUN's informations are provided by the Get-UnityLUNResource through the pipeline.
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $false,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'LUN Name or LUN Object')]
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

          # Determine input and convert to UnityLUN object
          Switch ($n.GetType().Name)
          {
            "String" {
              $LUN = get-UnityLUN -Session $Sess -Name $n
              $LUNID = $LUN.id
              $LUNName = $n
            }
            "UnityLUN" {
              Write-Verbose "Input object type is $($n.GetType().Name)"
              $LUNName = $n.Name
              If (Get-UnityLUN -Session $Sess -Name $n.Name) {
                        $LUNID = $n.id
              }
            }
          }

          If ($LUNID) {

            $UnityStorageRessource = Get-UnitystorageResource -Session $sess | ? {($_.Name -like $LUNName) -and ($_.luns.id -like $LUNID)}

            #Building the URI
            $URI = 'https://'+$sess.Server+'/api/instances/storageResource/' + $UnityStorageRessource.id
            Write-Verbose "URI: $URI"

            if ($pscmdlet.ShouldProcess($LUNName,"Delete LUN")) {
              #Sending the request
              $request = Send-UnityRequest -uri $URI -Session $Sess -Method 'DELETE'
            }

            If ($request.StatusCode -eq '204') {

              Write-Verbose "LUN with ID: $LUNID has been deleted"

            }
          } else {
            Write-Verbose "LUN $LUNName does not exist on the array $($sess.Name)"
          }
        }
      } else {
        Write-Host "You are no longer connected to EMC Unity array: $($Sess.Server)"
      }
    }
  }

  End {}
}

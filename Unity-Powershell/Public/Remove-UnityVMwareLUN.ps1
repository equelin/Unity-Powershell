Function Remove-UnityVMwareLUN {

  <#
      .SYNOPSIS
      Delete a VMware block LUN.
      .DESCRIPTION
      Delete a VMware block LUN.
      You need to have an active session with the array.
      .NOTES
      Written by Erwan Quelin under Apache licence
      .LINK
      https://github.com/equelin/Unity-Powershell
      .EXAMPLE
      Remove-UnityVMwareLUN -Name 'LUN01'

      Delete the VMware block LUN named 'LUN01'
      .EXAMPLE
      Get-UnityVMwareLUN -Name 'LUN01' | Remove-UnityVMwareLUN

      Delete the VMware block LUN named 'LUN01'. The LUN's informations are provided by the Get-UnityVMwareLUN through the pipeline.
  #>

    [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param (
    [Parameter(Mandatory = $false,HelpMessage = 'EMC Unity Session')]
    $session = ($global:DefaultUnitySession | where-object {$_.IsConnected -eq $true}),
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'LUN Name or LUN Object')]
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

          # Determine input and convert to UnityLUN object
          Switch ($n.GetType().Name)
          {
            "String" {
              $LUN = get-UnityVMwareLUN -Session $Sess -Name $n
              $LUNID = $LUN.id
              $LUNName = $n
            }
            "UnityLUN" {
              Write-Verbose "Input object type is $($n.GetType().Name)"
              $LUNName = $n.Name
              If ($LUN = Get-UnityVMwareLUN -Session $Sess -Name $n.Name) {
                        $LUNID = $n.id
              }
            }
          }

          If ($LUNID) {
            $LUN | Remove-UnityLUNResource -Session $Sess
          } else {
            Write-Verbose "VMware LUN $LUNName does not exist on the array $($sess.Name)"
          }
        }
      } else {
        Write-Information -MessageData "You are no longer connected to EMC Unity array: $($Sess.Server)"
      }
    }
  }

  End {}
}
